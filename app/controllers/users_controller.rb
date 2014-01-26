class UsersController < ApplicationController
  
  def log_in
    redirect_to user_omniauth_authorize_path(:google)
    cookies[:return_to] = session["user_return_to"]
  end

  def log_out
    sign_out
    redirect_to :root
  end

  def remove_user_selector
    render :layout => false
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to :root
  end
end
