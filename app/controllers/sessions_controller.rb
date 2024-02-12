# frozen_string_literal: true

class SessionsController < WebsiteController

  # This is contained within omniauth.
  skip_before_action :verify_authenticity_token

  ##
  # Responds to `POST /auth/:provider/callback`
  #
  def create
    auth_hash = request.env['omniauth.auth']
    if auth_hash and auth_hash[:uid]
      username = auth_hash[:uid].split('@').first
      user = User.find_or_create_by!(username: username)
      if user.medusa_admin?
        return_url = clear_and_return_return_path
        sign_in user
        redirect_to return_url
        return
      end
    end
    flash['error'] = sprintf('Sign-in failed. Ensure that you are a member '\
                             'of the %s AD group.',
                             ::Configuration.instance.medusa_admins_group)
    redirect_to root_url
  end

  ##
  # Responds to `DELETE /signout`
  #
  def destroy
    sign_out
    clear_and_return_return_path
    redirect_to root_url
  end


  protected

  def clear_and_return_return_path
    return_url = session[:return_to] || session[:referer] || admin_root_path
    session[:return_to] = session[:referer] = nil
    reset_session
    return_url
  end

end
