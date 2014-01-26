require 'mail'

class CloudMailIn

  def initialize params
    @params = params
  end

  def message
    @message ||= Mail.new @params[:message]
  end

  def addresses
    addresses = []
    addresses.concat message.to
    addresses.concat message.cc if message.cc
    addresses << @params[:to] if @params[:to] && !@params[:to].empty?
    addresses
  end

  def message_id
    message.message_id
  end

  def from
    message.from
  end

end
