require 'gmail'

class GmailService
  extend Resque::Plugins::Result
  @queue = :gmail_queue

  def self.connect(username, password)
    Gmail.connect!(username, password)
  end

  def logout
    @gmail.logout
  end

  def self.perform(meta_id=nil, list_name)
    email_array = filter_emails_by_destination(list_name)
    email_array.reverse[0..9].map do |email|
      Email.new(email.message, email.uid)
    end
  end

  def self.filter_emails_by_destination(list_name)
    gmail.inbox.emails(:to => list_name)
  end

  def self.gmail
    @gmail ||= connect(Settings.archive_address, Settings.archive_password)
  end

end
