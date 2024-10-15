class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  def create
    params[:user][:login] ||= params[:user][:email]

    self.resource = User.find_for_database_authentication(login: params[:user][:login])

    if resource && resource.valid_password?(params[:user][:password])
      sign_in(resource_name, resource)
      redirect_to after_sign_in_path_for(resource)
    else
      set_flash_message(:alert, :invalid, authentication_keys: 'login')
      redirect_to new_user_session_path
    end
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login])
  end
end
