class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  skip_before_action :verify_authenticity_token if :success_response?


  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
    return render file: Rails.root.join("public", "403.html"), :status => 403 if @user.nil?
    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
    sign_in @user
    redirect_to cookies[:return_to]
    cookies.delete(:return_to)
  end

  private

  def success_response?
    env['omniauth.auth']['extra']['response'].class == OpenID::Consumer::SuccessResponse
  end

end