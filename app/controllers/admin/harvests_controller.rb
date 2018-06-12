module Admin

  class HarvestsController < ControlPanelController

    ##
    # Responds to PATCH /admin/harvests/:key/abort
    #
    def abort
      harvest = Harvest.find_by_key(params[:harvest_key])
      raise ActiveRecord::RecordNotFound unless harvest

      begin
        harvest.update!(status: Harvest::Status::ABORTED, ended_at: Time.now)
      rescue => e
        flash['error'] = "#{e}"
      else
        flash['success'] = 'Harvest aborted.'
      ensure
        redirect_back fallback_location: admin_harvest_path(harvest)
      end
    end

    ##
    # Responds to GET /admin/harvests
    #
    def index
      @limit = Option::integer(Option::Keys::DEFAULT_RESULT_WINDOW)
      @start = params[:start] ? params[:start].to_i : 0
      @harvests = Harvest.all.order(created_at: :desc)

      @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1
      @count = @harvests.count
      @harvests = @harvests.offset(@start).limit(@limit)

      respond_to do |format|
        format.js
        format.html
      end
    end

    ##
    # Responds to GET /admin/harvests/:key
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
