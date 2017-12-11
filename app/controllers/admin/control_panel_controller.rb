module Admin

  class ControlPanelController < ApplicationController

    layout 'admin/application'

    before_action :signed_in_user
    after_action :flash_in_response_headers

  end

end
