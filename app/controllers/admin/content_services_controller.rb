module Admin

  class ContentServicesController < ControlPanelController

    HARVEST_WINDOW_SIZE = 5

    before_action :load_model, only: [:destroy, :edit, :show, :update]
    before_action :require_admin, except: [:index, :show]

    ##
    # Responds to DELETE /admin/content-services/:id/element-mappings
    #
    def clear_element_mappings
      service = ContentService.find_by_key(params[:content_service_key])
      raise ActiveRecord::RecordNotFound unless service

      begin
        service.element_mappings.destroy_all
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = 'Element mappings cleared. Reindex to '\
            'repopulate the element list.'
      ensure
        redirect_back fallback_location: admin_content_service_path(service)
      end
    end

    ##
    # Responds to POST /admin/content-services
    #
    def create
      begin
        service = ContentService.create!(sanitized_params)
      rescue => e
        handle_error(e)
        @content_service = ContentService.new
        render 'new'
      else
        flash['success'] = "Content service #{service} created."
        redirect_to admin_content_service_path(service)
      end
    end

    ##
    # Responds to DELETE /admin/content-services/:key
    #
    def destroy
      begin
        @content_service.destroy!
      rescue => e
        handle_error(e)
        redirect_to admin_content_services_url
      else
        flash['success'] = "Content service \"#{@content_service}\" deleted."
        redirect_to admin_content_services_url
      end
    end

    ##
    # Responds to GET /admin/content-services/:key/edit
    #
    def edit
    end

    ##
    # Responds to POST /admin/content-services/:key/harvest
    #
    def harvest
      @content_service = ContentService.find_by_key(params[:content_service_key])
      raise ActiveRecord::RecordNotFound unless @content_service

      begin
        @content_service.harvest_items_async

        flash['success'] = 'Harvesting will begin shortly.'
      rescue => e
        flash['error'] = "#{e}"
      ensure
        redirect_back fallback_location: admin_content_service_path(@content_service)
      end
    end

    ##
    # Responds to GET /admin/content-services
    #
    def index
      @content_services = ContentService.order(:name)
    end

    ##
    # Responds to GET /admin/content-services/new
    #
    def new
      @content_service = ContentService.new
    end

    ##
    # Responds to POST /admin/content-services/:key/purge
    #
    def purge
      @content_service = ContentService.find_by_key(params[:content_service_key])
      raise ActiveRecord::RecordNotFound unless @content_service
      begin
        @content_service.send_delete_all_items_sns
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = "Purging all items from #{@content_service.name} "\
            "in the background. This may take a few minutes."
      ensure
        redirect_back fallback_location: admin_content_service_path(@content_service)
      end
    end

    ##
    # Responds to GET /admin/content-services/:key
    #
    def show
      @harvests = @content_service.harvests
                      .order(created_at: :desc)
                      .limit(HARVEST_WINDOW_SIZE)
    end

    ##
    # Responds to PATCH /admin/content-services/:key
    #
    def update
      begin
        @content_service.update_attributes!(sanitized_params)

        params[:content_service][:element_mappings].each do |k, v|
          ElementMapping.find(k).update!(element_def_id: v.values[0])
        end
      rescue => e
        handle_error(e)
        render 'edit'
      else
        flash['success'] = 'Content service updated. Note that if any '\
            'element mappings were changed, the service will need to be '\
            'reharvested.'
        redirect_to admin_content_service_path(@content_service)
      end
    end

    private

    def load_model
      @content_service = ContentService.find_by_key(params[:key])
      raise ActiveRecord::RecordNotFound unless @content_service
    end

    def sanitized_params
      params.require(:content_service).permit(:description, :element_mappings, :key, :name, :uri)
    end

  end

end