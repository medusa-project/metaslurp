# frozen_string_literal: true

module Admin

  class ControlPanelController < ApplicationController

    layout 'admin/application'

    before_action :signed_in_user
    after_action :flash_in_response_headers

    protected

    def require_admin
      unless current_user.medusa_admin?
        flash['error'] = 'You are not authorized to access this resource.'
        redirect_to admin_root_url
      end
    end

  end

end
