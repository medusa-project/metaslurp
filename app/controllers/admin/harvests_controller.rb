module Admin

  class HarvestsController < ControlPanelController

    PERMITTED_PARAMS = [:content_service_id, :status]

    ##
    # Responds to `PATCH /admin/harvests/:key/abort`
    #
    def abort
      harvest = Harvest.find_by_key(params[:harvest_key])
      raise ActiveRecord::RecordNotFound unless harvest

      begin
        harvest.abort
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = 'Harvest aborted.'
      ensure
        redirect_back fallback_location: admin_harvest_path(harvest)
      end
    end

    ##
    # Responds to `DELETE /admin/harvests/:key`
    #
    def destroy
      harvest = Harvest.find_by_key(params[:key])
      raise ActiveRecord::RecordNotFound unless harvest
      begin
        harvest.destroy!
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = 'Harvest deleted.'
      ensure
        redirect_to admin_harvests_path
      end
    end

    ##
    # Responds to GET `/admin/harvests`
    #
    def index
      @limit = Option::integer(Option::Keys::DEFAULT_RESULT_WINDOW)
      @start = params[:start] ? params[:start].to_i : 0
      @harvests = Harvest.all.order(created_at: :desc)

      if params[:content_service_id].present?
        @harvests = @harvests.where(content_service_id: params[:content_service_id])
      end
      if params[:status].present?
        @harvests = @harvests.where(status: params[:status])
      end

      @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
      @count = @harvests.count
      @harvests = @harvests.offset(@start).limit(@limit)

      respond_to do |format|
        format.js
        format.html
      end
    end

    ##
    # Responds to GET `/admin/harvests/:key`
    #
    def show
      @harvest = Harvest.find_by_key(params[:key])
      raise ActiveRecord::RecordNotFound unless @harvest

      respond_to do |format|
        format.js
        format.html
      end
    end

  end

end
