require 'spec_helper'

describe Email do
    it 'can extract a list from a mail' do
        mail = Mail.new do
            to %W[x@y.z consulting@#{Settings.domain}]
            from 'a@b.c'
            body 'some text'
            subject 'hello'
            date "2013-01-01".to_date
        end

        email_wrapper = Email.new(mail, 5)
        email_wrapper.lists.should == ["consulting"]
    end
end