require 'spec_helper'

describe ListsHelper do
  it "can create an email list" do
    email_list('name').should == "name@#{Settings.domain}"
  end

  it "can create a mail to link" do
    email_list_mail_to('name').should == "<a href=\"mailto:name@#{Settings.domain}\">name</a>"
  end

  it "can get all subscribers but one in a select ready helper" do
    bobby = FactoryGirl.create(:subscriber, :email => "bobby@#{Settings.organization_domain}")
    sarah = FactoryGirl.create(:subscriber, :email => "sarah@#{Settings.organization_domain}")
    list = FactoryGirl.create(:list, :subscribers => [bobby, sarah])

    users = get_all_subscribers_except list, sarah
    users.size.should == 1
  end

  it "can display an empty date" do
    list = FactoryGirl.create(:list)
    list_display_date(list).should == ''
  end

  it "can display a date" do
    now = DateTime.parse '2012/3/3'
    list = FactoryGirl.create(:list, :last_sent_time => now)
    list_display_date(list).should == 'March 03, 2012'
  end

end
