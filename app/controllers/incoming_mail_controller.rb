class IncomingMailController < ApplicationController    
  layout false

  @@message_ids = []

  skip_before_filter :verify_authenticity_token
    
  def create
    render :nothing => true

    email = CloudMailIn.new params

    return if @@message_ids.include? email.message_id
    @@message_ids << email.message_id

    email_exploder = ListExploder.new
    @new_destinations = email_exploder.explode email.addresses, email.from[0]

    return if @new_destinations.empty?

    ListMailer.distribute @new_destinations, email.message
  end
end
