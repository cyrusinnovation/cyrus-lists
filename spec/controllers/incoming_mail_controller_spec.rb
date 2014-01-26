require 'spec_helper'
require 'mail'

describe IncomingMailController do

  SIMPLE_EMAIL = "" "
MIME-Version: 1.0
Sender: sherlock@#{Settings.organization_domain}
Received: by 10.182.43.170 with HTTP; Wed, 21 Mar 2012 11:10:45 -0700 (PDT)
Date: Wed, 21 Mar 2012 14:10:45 -0400
Delivered-To: sherlock@#{Settings.organization_domain}
X-Google-Sender-Auth: 0fwQr9QxgQYXk2edEcYb-HtZboc
Message-ID: <CAMPHzqZyvJHtfhAc24b-nFw_Hf-7TxrynSWH=_vFJqkvVcWwQA@mail.gmail.com>
Subject: This is a test
From: Dionysus <dionysus@#{Settings.organization_domain}>
To: sherlockonly@#{Settings.domain}
Content-Type: multipart/alternative; boundary=000e0cd306c6d8b2aa04bbc4b545

--000e0cd306c6d8b2aa04bbc4b545
Content-Type: text/plain; charset=UTF-8

WOO HEEE HOOOO

--000e0cd306c6d8b2aa04bbc4b545
Content-Type: text/html; charset=UTF-8

WOO HEEE HOOOO

--000e0cd306c6d8b2aa04bbc4b545--
" ""

  before { ListMailer.sender.deliveries.clear }

  it "should send all deliveries through a default archive email" do
    archive_address = create(:subscriber, :email => Settings.archive_address)


    subscriber = create(:subscriber, :email => "dionysus2@#{Settings.organization_domain}")

    list = create(:list, :name => 'yummy',
                              :subscribers => [subscriber])

    mail = make_msg

    post :create, {:message => mail.to_s}
    recipients = assigns(:new_destinations)
    recipients.should include(archive_address.email)
    ListMailer.sender.deliveries.size.should == 2
  end

  it "sends an email to the archive if the list only includes the sender" do
    archive_address = create(:subscriber, :email => Settings.archive_address)
    subscriber_and_sender = create(:subscriber, :email => "dionysus@#{Settings.organization_domain}")

    list = create(:list, :name => 'yummy',:subscribers => [subscriber_and_sender])

    mail = make_msg(subscriber_and_sender.email)

    post :create, {:message => mail.to_s}
    recipients = assigns(:new_destinations)
    recipients.should include(archive_address.email)
    ListMailer.sender.deliveries.size.should == 1
  end

  it "sends an email to the archive if the list has no subscribers" do
    archive_address = create(:subscriber, :email => Settings.archive_address)
    list = create(:list, :name => 'yummy', :subscribers => [])
    mail = make_msg

    post :create, {:message => mail.to_s}
    recipients = assigns(:new_destinations)
    recipients.should include(archive_address.email)
    ListMailer.sender.deliveries.size.should == 1
  end

  it "doesnt send an email to the archive if it goes to the catchall email" do
    archive_address = create(:subscriber, :email => Settings.archive_address)

    mail = make_msg "dionysus@#{Settings.organization_domain}", "doesnotexist@#{Settings.domain}"

    post :create, {:message => mail.to_s}
    recipients = assigns(:new_destinations)
    recipients.should_not include(archive_address.email)
    ListMailer.sender.deliveries.size.should == 1
  end

  it "can receive some emails" do
    subscriber = create(:subscriber, :email => "dionysus@#{Settings.organization_domain}")
    subscriber2 = create(:subscriber, :email => "dionysus2@#{Settings.organization_domain}")
    subscriber3 = create(:subscriber, :email => "sender@ant.com")

    list = create(:list, :name => 'yummy',
                              :subscribers => [subscriber, subscriber2, subscriber3])

    mail = make_msg

    post :create, {:message => mail.to_s}
    ListMailer.sender.deliveries.size.should == 4
  end

  it "can receive a to with a full email address" do
    subscriber = create(:subscriber, :email => "dionysus@#{Settings.organization_domain}")
    list = create(:list, :name => 'yummy', :subscribers => [subscriber])

    post :create, message: make_msg('bobby@bob.com').to_s
    ListMailer.sender.deliveries.size.should == 2
  end

  it "will not work on the same email twice" do
    subscriber = create :subscriber, :email => "ag@ci.com"
    create :list, :name => 'sherlockonly', :subscribers => [subscriber]

    mail = Mail.new SIMPLE_EMAIL

    post :create, message: mail.to_s
    post :create, message: mail.to_s

    ListMailer.sender.deliveries.size.should eq 2
  end

  it "lists in the cc will get expanded as well" do
    subscriber = create :subscriber, :email => "ag@ci.com"
    subscriber2 = create :subscriber, :email => "jo@ci.com"
    create :list, :name => 'list_with_ag', :subscribers => [subscriber]
    create :list, :name => 'list_with_jo',
                       :subscribers => [subscriber2],
                       :category => create(:category, :position => 10)

    mail = make_msg "dionysus@#{Settings.organization_domain}", "list_with_ag@#{Settings.domain}"
    mail.cc = %W(list_with_jo@#{Settings.domain})

    post :create, message: mail.to_s

    ListMailer.sender.deliveries.size.should eq 3
  end

  it "reads the to parameter as well as the message string" do
    list = create :list_with_one_subscriber, :name => 'yummy'
    mail = make_msg "dionysus@#{Settings.organization_domain}", 'nolist@boom.com'
    post :create, {message: mail.to_s, to: "yummy@#{Settings.domain}"}
    ListMailer.sender.deliveries.size.should eq 2
  end

  it "only adds the 'to' parameter if it is passed in" do
    list = create :list_with_one_subscriber, name: 'yummy'
    mail = make_msg "dionysus@#{Settings.organization_domain}", 'nolist@boom.com'
    post :create, message: mail.to_s
    post :create, message: mail.to_s, to: ''
    ListMailer.sender.deliveries.size.should eq 0
  end

  it "will not display a destination list if it was not explicitly written" do
    list = create :list_with_one_subscriber, name: 'yummy'
    mail = make_msg 'a@b.c', 'list@outside.com'
    post :create, message: mail.to_s, to: "yummy@#{Settings.domain}"
    sent = ListMailer.sender.deliveries[0]
    new_mail = Mail.new sent[:body]
    new_mail.to.should eq %w(list@outside.com)
  end

  private

  def make_msg(from="sender@#{Settings.organization_domain}",
      to="yummy@#{Settings.domain}",
      subject="Hello there",
      body="Oh my, what a body")
    mail = Mail.new do |m|
      m.to = to
      m.from = from
      m.subject = subject
      m.body = body
    end
    mail
  end

end
