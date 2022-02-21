class ApplicationController < ActionController::Base

  LOGGER = CustomLogger.new(ApplicationController)

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  before_action :setup
  after_action :flash_in_response_headers

  # N.B.: these must be listed in order of most generic to most specific.
  rescue_from StandardError, with: :rescue_internal_server_error
  rescue_from ActionController::InvalidAuthenticityToken, with: :rescue_invalid_auth_token
  rescue_from ActionController::InvalidCrossOriginRequest, with: :rescue_invalid_cross_origin_request
  rescue_from ActionController::UnknownFormat, with: :rescue_unknown_format
  rescue_from ActiveRecord::RecordNotFound, with: :rescue_not_found

  def setup
    @keep_flash = false
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_path, notice: 'Please log in.'
    end
  end

  protected

  ##
  # Logs the given error and sets the flash to it.
  #
  # @param e [Exception, String]
  #
  def handle_error(e)
    unless e.kind_of?(ActiveRecord::RecordInvalid)
      LOGGER.warn(e)
      flash['error'] = "#{e}"
    end
    response.headers['X-DL-Result'] = 'error'
  end

  ##
  # Normally the flash is discarded after being added to the response headers
  # (see flash_in_response_headers). Calling this method will save it, enabling
  # it to work with redirects. (Notably, it works different than flash.keep.)
  #
  def keep_flash
    @keep_flash = true
  end

  def signin_path
    if Rails.env.demo? || Rails.env.production?
      host = Metaslurp::Application.shibboleth_host
      "/Shibboleth.sso/Login?target=https://#{host}/auth/shibboleth/callback"
    else
      "/auth/developer"
    end
  end

  ##
  # Sends an Enumerable object in chunks as an attachment. Streaming requires
  # a web server capable of it (not WEBrick).
  #
  def stream(enumerable, filename)
    headers['X-Accel-Buffering'] = 'no'
    headers['Cache-Control'] ||= 'no-cache'
    headers.delete('Content-Length')
    headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    self.response_body = enumerable
  end

  ##
  # Stores the flash message and type ('error' or 'success') in the response
  # headers, where they can be accessed by an ajax callback. Afterwards, the
  # "normal" flash is cleared, which prevents it from working with redirects.
  # To prevent this, a controller should call keep_flash before redirecting.
  #
  def flash_in_response_headers
    if request.xhr?
      response.headers['X-DL-Message-Type'] = 'error' unless
          flash['error'].blank?
      response.headers['X-DL-Message-Type'] = 'success' unless
          flash['success'].blank?
      response.headers['X-DL-Message'] = flash['error'] unless
          flash['error'].blank?
      response.headers['X-DL-Message'] = flash['success'] unless
          flash['success'].blank?
      flash.clear unless @keep_flash
    end
  end

  private

  def rescue_internal_server_error(exception)
    io = StringIO.new
    io << "Error on #{request.url}\n"
    io << "Class:   #{exception.class}\n"
    io << "Message: #{exception.message}\n"
    io << "Time:    #{Time.now.iso8601}\n"
    io << "User:    #{current_user.username}\n" if current_user
    io << "\nStack Trace:\n"
    exception.backtrace.each do |line|
      io << line
      io << "\n"
    end

    @message = io.string
    Rails.logger.error(@message)

    unless Rails.env.development?
      MetaslurpMailer.error(@message).deliver_now
    end

    respond_to do |format|
      format.html do
        render "errors/internal_server_error",
               status: :internal_server_error,
               content_type: "text/html"
      end
      format.all do
        render plain: "500 Internal Server Error",
               status: :internal_server_error,
               content_type: "text/plain"
      end
    end
  end

  ##
  # By default, Rails logs {ActionController::InvalidAuthenticityToken}s at
  # error level. This only bloats the logs, so we handle it differently.
  #
  def rescue_invalid_auth_token
    render plain: "Invalid authenticity token.", status: :bad_request
  end

  ##
  # By default, Rails logs {ActionController::InvalidCrossOriginRequest}s at
  # error level. This only bloats the logs, so we handle it differently.
  #
  def rescue_invalid_cross_origin_request
    render plain: "Invalid cross-origin request.", status: :bad_request
  end

  def rescue_not_found
    message = 'This resource does not exist.'
    respond_to do |format|
      format.html do
        render 'errors/error', status: :not_found, locals: {
          status_code: 404,
          status_message: 'Not Found',
          message: message
        }
      end
      format.json do
        render 'errors/error', status: :not_found, locals: { message: message }
      end
      format.all do
        render plain: "404 Not Found", status: :not_found,
               content_type: "text/plain"
      end
    end
  end

  def rescue_unknown_format
    render plain: "Sorry, we aren't able to provide the requested format.",
           status: :unsupported_media_type
  end

end
