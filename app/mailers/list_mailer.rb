require 'net/smtp'

class SmtpSender
  SMTP_HOST = ActionMailer::Base.smtp_settings[:address]
  SMTP_PORT = ActionMailer::Base.smtp_settings[:port]
  SMTP_USER = ActionMailer::Base.smtp_settings[:user_name]
  SMTP_PASSWORD = ActionMailer::Base.smtp_settings[:password]

  SMTP_SERVER_ADDRESS = Settings.smtp_server_address

  def send &block
    smtp = Net::SMTP.new(SMTP_HOST, SMTP_PORT)
    smtp.enable_starttls
    smtp.start(SMTP_SERVER_ADDRESS, SMTP_USER, SMTP_PASSWORD, :login) do |smtp|
      yield smtp
    end
  end
end

class TestSender
  class SillySmtp
    def initialize test_sender
      @test_sender = test_sender
    end
    
    def send_message mail_str, from, to
      @test_sender.deliveries << { :body => mail_str, :from => from, :to => to }
    end
  end
  
  attr_accessor :deliveries
  def initialize
    @deliveries = []
  end
  
  def send &block
    yield(SillySmtp.new self)
  end
end

class ListMailer
  include Singleton

  def self.sender
    @sender ||= ActionMailer::Base.delivery_method == :test ? TestSender.new : SmtpSender.new
  end

  def self.distribute emails, mail
    sender.send do |smtp|
      emails.collect do |to_address|
        mail['Delivered-To'] = to_address
        smtp.send_message mail.to_s, mail.from, to_address
      end
    end
  end

end
