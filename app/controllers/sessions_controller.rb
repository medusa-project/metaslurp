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
        # We can access other information via auth_hash[:extra][:raw_info][key]
        # where key is one of the shibboleth* keys in shibboleth.yml
        # (which have to correspond to passed attributes).
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

  ##
  # N.B.: OmniAuth responds to `/auth/developer` only via `POST`. This route
  # responds only via `GET`.
  #
  def new
    redirect_to root_url
  end

  protected

  def clear_and_return_return_path
    return_url = session[:return_to] || session[:referer] || admin_root_path
    session[:return_to] = session[:referer] = nil
    reset_session
    return_url
  end

  def shibboleth_login_path(host)
    "/Shibboleth.sso/Login?target=https://#{host}/auth/shibboleth/callback"
  end

end
