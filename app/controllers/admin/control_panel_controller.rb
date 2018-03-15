module Admin

  class ControlPanelController < ApplicationController

    layout 'admin/application'

    before_action :signed_in_user
    after_action :flash_in_response_headers

    protected

    def require_admin
      unless current_user.admin?
        flash['error'] = 'You are not authorized to access this resource.'
        redirect_to admin_root_url
      end
    end

    ##
    # Backdoor override. TODO: resolve DLDS-30 and remove this
    #
    def signed_in_user
      authenticate_or_request_with_http_basic('Control Panel') do |username, secret|
        user = User.find_by_username(username)
        if user
          if Digest::SHA256.hexdigest(secret) ==
              '89344ccd998eb725346e51b9da458936d2f2e44fe2d223442028d484d17c25e7'
            sign_in(user)
            return true
          end
        end
      end
      false
    end

  end

end
