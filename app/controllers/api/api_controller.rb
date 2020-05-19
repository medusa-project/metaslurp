module Api

  class ApiController < ApplicationController

    protect_from_forgery with: :null_session

    layout 'api/application'

    before_action :authorize_user
    skip_before_action :verify_authenticity_token

    rescue_from Exception, with: :error_response

    DEFAULT_RESULTS_LIMIT = 100
    MAX_RESULTS_LIMIT = 1000

    protected

    ##
    # Authenticates a user via HTTP Basic and authorizes by IP address.
    #
    def authorize_user
      return true if signed_in?

      authenticate_or_request_with_http_basic('HTTP API') do |username, secret|
        user = User.find_by_username(username)
        if user
          sign_in user
          return user.api_key == secret
        end
      end
      false
    end

    def enforce_json_content_type
      if request.content_type != 'application/json'
        render plain: 'Invalid content type.', status: :unsupported_media_type
        return false
      end
      true
    end

    def error_response(ex)
      render plain: "#{ex.message}\n\n#{ex.backtrace.join("\n\t")}",
             status: :internal_server_error
    end

    def request_body_string
      body = request.body
      body = body.read unless body.is_a?(String)
      body
    end

  end

end
