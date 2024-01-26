# frozen_string_literal: true

module Admin

  class ConfigurationController < ControlPanelController

    before_action :require_admin

    def index
    end

    ##
    # Responds to PATCH /admin/configuration/update
    #
    def update
      begin
        ActiveRecord::Base.transaction do
          params[:configuration].to_unsafe_hash.each_key do |key|
            Option.set(key, params[:configuration][key])
          end
        end
      rescue => e
        handle_error(e)
        render :index
      else
        flash['success'] = 'Configuration updated.'
        redirect_back fallback_location: admin_configuration_path
      end
    end

  end

end
