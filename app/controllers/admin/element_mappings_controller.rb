module Admin

  class ElementMappingsController < ControlPanelController

    ##
    # Responds to DELETE /admin/content-services/:content_service_id/element-mappings/:id
    #
    def destroy
      mapping = ElementMapping.find(params[:id])
      raise ActiveRecord::RecordNotFound unless mapping
      begin
        mapping.destroy!
      rescue => e
        handle_error(e)
      else
        flash['success'] = "Element mapping \"#{mapping}\" deleted."
      ensure
        redirect_back fallback_location: admin_content_service_path(params[:content_service_key])
      end
    end

  end

end