class SubscribersController < ApplicationController

  def index
    @subscribers =
        List.find(params[:list_id]).subscribers.collect do |subscriber|
          subscriber.email
        end.sort
    render :layout => false
  end
end