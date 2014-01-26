require 'spec_helper'

describe GmailService do

  let(:message) {
    stub("message",
         :subject => "subject",
         :date => 'June 20th, 2012',
         multipart?: false,
         :body => stub("text", :decoded => "BODY")
    )
  }
  let(:gmail_message) {
    stub("gmail_message",
         uid: 93,
         envelope: mock(to: nil, cc: nil),
         message: message,
         date: "2012-08-20 15:00:00 -0400",
         from: [stub('name', name: "Rex Madden")]
    )
  }

  it "queries based on list name" do
    mailbox = stub('mailbox')
    mailbox.should_receive(:emails).with(:to => "some_list").and_return([])
    gmail_client_stub = stub('Gmail Stub', :inbox => mailbox)
    Gmail.should_receive(:connect!).and_return(gmail_client_stub)

    GmailService.perform("some_list")
  end

  it "returns a list of emails" do
    GmailService.
        stub(:filter_emails_by_destination).
        with('tester2').
        and_return([gmail_message])

    GmailService.perform("tester2").first.should be_a_kind_of(Email)
  end

end
