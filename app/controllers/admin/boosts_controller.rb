# frozen_string_literal: true

module Admin

  class BoostsController < ControlPanelController

    PERMITTED_PARAMS = [:boost, :field, :value]

    before_action :require_admin, except: :index

    ##
    # Responds to POST /admin/boosts
    #
    def create
      @boost = Boost.new(sanitized_params)
      begin
        @boost.save!
      rescue ActiveRecord::RecordInvalid
        response.headers['X-DL-Result'] = 'error'
        render partial: 'admin/shared/validation_messages',
               locals: { entity: @boost }
      rescue => e
        handle_error(e)
        keep_flash
        render 'create'
      else
        response.headers['X-DL-Result'] = 'success'
        flash['success'] = 'Boost created.'
        keep_flash
        render 'create' # create.js.erb will reload the page
      end
    end

    ##
    # Responds to DELETE /admin/boosts/:id
    #
    def destroy
      boost = Boost.find(params[:id])
      begin
        boost.destroy!
      rescue => e
        handle_error(e)
      else
        flash['success'] = 'Boost deleted.'
      ensure
        redirect_back fallback_location: admin_boosts_path
      end
    end

    ##
    # Responds to GET /admin/boosts/:id/edit
    #
    def edit
      boost = Boost.find(params[:id])

      render partial: 'admin/boosts/form', locals: { boost: boost }
    end

    ##
    # Responds to GET /admin/boosts
    #
    def index
      @boosts = Boost.order(:field)
      @new_boost = Boost.new
    end

    ##
    # Responds to PATCH /admin/boosts/update
    #
    def update
      boost = Boost.find(params[:id])

      begin
        boost.update!(sanitized_params)
      rescue ActiveRecord::RecordInvalid
        response.headers['X-DL-Result'] = 'error'
        render partial: 'admin/shared/validation_messages',
               locals: { entity: boost }
      rescue => e
        handle_error(e)
        keep_flash
        render 'update'
      else
        flash['success'] = 'Boost updated.'
        keep_flash
        render 'update' # update.js.erb will reload the page
      end
    end

    private

    def sanitized_params
      params.require(:boost).permit(PERMITTED_PARAMS)
    end

  end

end
