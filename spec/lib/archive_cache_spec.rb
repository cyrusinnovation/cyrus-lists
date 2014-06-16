require 'spec_helper'

describe ArchiveCache do

  describe "#update", :redis => true do

    it {should respond_to(:unread_messages) }

    it "retrieves all lists" do
      list = FactoryGirl.create :list
      List.should_receive(:all).and_return([list])

      job = mock("Job", meta_id: 1, succeeded?: true, result: "result")

      GmailService.should_receive(:enqueue).exactly(1).times.and_return(job)
      GmailService.should_receive(:get_meta).exactly(1).times.and_return(job)

      ArchiveCache.update
    end

    it "calls the GmailService#enqueue and #get_meta for each record" do
      FactoryGirl.create(:list)

      job = mock("Job", meta_id: 1, succeeded?: true, result: nil)

      GmailService.should_receive(:enqueue).exactly(1).times.and_return(job)
      GmailService.should_receive(:get_meta).exactly(1).times.and_return(job)

      ArchiveCache.update
    end

    it "writes to the cache" do
      list = FactoryGirl.create :list

      job = mock("Job", meta_id: 1, succeeded?: true, result: "result")

      GmailService.should_receive(:enqueue).exactly(1).times.and_return(job)
      GmailService.should_receive(:get_meta).exactly(1).times.and_return(job)

      rails_cache = mock("Cache", fetch: mock, delete: mock)
      rails_cache.should_receive(:fetch).with(list.name).at_least(1).times
      Rails.should_receive(:cache).at_least(1).times.and_return(rails_cache)

      ArchiveCache.update
    end
  end

  describe "retrieving incremental updates" do
    before do
      Rails.cache.delete("consulting")
    end
    it "retrieves all unread messages" do
      gmail_message = mock(message: 'And I, Jack! The pumpkin king!', uid: 6)
      email = Email.new(gmail_message.message, 6)

      mailbox = stub("gmail mailbox")
      mailbox.should_receive(:emails).with(:unread).and_return([gmail_message])
      gmail_client_stub = stub('Gmail Stub', :inbox => mailbox)
      Gmail.should_receive(:connect!).and_return(gmail_client_stub)

      archive_cache = ArchiveCache.new
      archive_cache.unread_messages.should eq [email]
    end

    it "adds messages to their list's cache" do
      archive_cache = ArchiveCache.new
      message = "I'm a message!"
      archive_cache.add_to_cache("consulting", message)
      Rails.cache.read("consulting").count.should == 1
    end

    it "keeps cache length at 10" do
      archive_cache = ArchiveCache.new
      message = "message!"
      messages = (message * 10).split("!")
      Rails.cache.write("consulting", messages)
      Rails.cache.read("consulting").count.should == 10

      archive_cache.add_to_cache("consulting", "I'm a new message")
      Rails.cache.read("consulting").count.should == 10
    end

    it "adds unread messages to queue" do
      email_archive = ArchiveCache.new

      mail = Mail.new do
        to %W[x@y.z consulting@#{Settings.domain}]
        from 'a@b.c'
        body 'some text'
        subject 'hello'
        date "2013-01-01".to_date
      end

      email_wrapper = Email.new(mail, 5)
      emails = [ email_wrapper ]

      email_archive.stub(:unread_messages).and_return(emails)
      email_archive.update_unread_messages

      Rails.cache.read("consulting").should include(email_wrapper.to_hash)
    end
  end
end
