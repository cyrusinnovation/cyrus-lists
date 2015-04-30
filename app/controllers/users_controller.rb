class UsersController < ApplicationController
  def remove_user_selector
    render :layout => false
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to :root
  end
end
