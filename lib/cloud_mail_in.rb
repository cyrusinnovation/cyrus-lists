require 'mail'

class CloudMailIn

  def initialize params
    @params = params
  end

  def message
    @message ||= Mail.new @params[:message]
  end

  def addresses
    [message.to, message.cc, @params[:to]].flatten.compact
  end

  def message_id
    message.message_id
  end

  def from
    message.from
  end

end
