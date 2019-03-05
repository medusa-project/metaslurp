class SessionsController < WebsiteController

  # This is contained within omniauth.
  skip_before_action :verify_authenticity_token

  ##
  # Simple temporary backdoor while we work on getting Shibboleth working
  # properly.
  #
  def backdoor
    users = {
        '8013014944eacdae3874dbda4762e45d7733387452ba48f915084372090453b9': 'alexd'
    }

    provided_sha256 = Digest::SHA2.hexdigest(params[:key])
    username = users[provided_sha256.to_sym]

    if username
      user = User.find_by_username(username)
      if user
        return_url = clear_and_return_return_path
        sign_in user
        redirect_to return_url
        return
      end
    end
    flash['error'] = 'Sign-in failed.'
    redirect_to root_url
  end

  ##
  # Responds to POST /auth/:provider/callback
  #
  def create
    Rails.logger.error('SessionsController.create()')
    auth_hash = request.env['omniauth.auth']
    if auth_hash and auth_hash[:uid]
      username = auth_hash[:uid].split('@').first
      user = User.find_by_username(username)
      if user
        return_url = clear_and_return_return_path
        sign_in user
        # We can access other information via auth_hash[:extra][:raw_info][key]
        # where key is one of the shibboleth* keys in shibboleth.yml
        # (which have to correspond to passed attributes).
        redirect_to return_url
        return
      end
    end
    flash['error'] = 'Sign-in failed.'
    redirect_to root_url
  end

  def destroy
    sign_out
    redirect_back fallback_location: root_path
  end

  ##
  # Responds to GET /signin
  #
  def new
    session[:referer] = request.env['HTTP_REFERER']
    if Rails.env.production?
      redirect_to(shibboleth_login_path(Metaslurp::Application.shibboleth_host))
    else
      redirect_to('/auth/developer')
    end
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
