class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :user_can_modify_list?

  def user_can_modify_list? user, list_id
    list = List.find list_id
    denied_access unless list.can_user_modify?(user)
  end
  
  def denied_access
    render :nothing => true, :status => 403
  end

 def after_sign_in_path_for(resource_or_scope)
   case resource_or_scope
   when :user, User
     store_location = cookies[:return_to]
     cookies[:return_to] = nil
     (store_location.nil?) ? "/" : store_location.to_s
   else
     super
   end
 end
  
end
