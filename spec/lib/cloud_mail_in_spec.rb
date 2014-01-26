require 'spec_helper'

describe CloudMailIn do

  mail = Mail.new do |m|
    m.to = %w(a@b.c b@c.d)
    m.cc = %w(c@d.e)
    m.subject = 'Subject'
    m.body = 'Body'
  end
  params = {message: mail.to_s,
            to: 'anon@dev.null'}
  let!(:cmi) { CloudMailIn.new params }

  it "should give the email as a Mail object when asked for the message" do
    cmi.message.should be_instance_of Mail::Message
  end

  it "should give a list of destinations that includes CC and the 'to' field in the params" do
    cmi.addresses.sort.should eq %w(a@b.c anon@dev.null b@c.d c@d.e)
  end

end