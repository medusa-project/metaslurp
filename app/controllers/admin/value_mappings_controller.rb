module Admin

  class ValueMappingsController < ControlPanelController

    PERMITTED_PARAMS = [:element_def_name, :local_value, :source_value]

    before_action :set_permitted_params

    ##
    # Responds to POST /admin/elements/:element_def_name/value-mappings/create
    #
    def create
      element = ElementDef.find_by_name(params[:element_def_name])
      raise ActiveRecord::RecordNotFound unless element
      mapping = element.value_mappings.build(sanitized_params)
      mapping.save!
    rescue ActiveRecord::RecordInvalid
      response.headers['X-DL-Result'] = 'error'
      render partial: 'admin/shared/validation_messages',
             locals: { entity: mapping }
    rescue ActiveRecord::RecordNotUnique => e
      response.headers['X-DL-Result'] = 'error'
      render partial: 'admin/shared/validation_messages',
             locals: { entity: e }
    rescue => e
      handle_error(e)
      keep_flash
      render 'create'
    else
      response.headers['X-DL-Result'] = 'success'
      flash['success'] = 'Value mapping created.'
      keep_flash
      render 'create' # create.js.erb will reload the page
    end

    ##
    # Responds to DELETE /admin/elements/:element_def_name/value-mappings/:id
    #
    def destroy
      mapping = ValueMapping.find(params[:id])
      mapping.destroy!
    rescue => e
      handle_error(e)
    else
      flash['success'] = 'Value mapping deleted.'
    ensure
      redirect_back fallback_location: admin_element_def_path(mapping.element_def)
    end

    ##
    # Responds to GET /admin/elements/:element_def_name/value-mappings/:id/edit (XHR only)
    #
    def edit
      mapping = ValueMapping.find(params[:id])

      render partial: 'admin/value_mappings/form',
             locals: { value_mapping: mapping }
    end

    ##
    # Responds to PATCH /admin/elements/:name/value-mappings/:id
    #
    def update
      mapping = ValueMapping.find(params[:id])
      mapping.update!(sanitized_params)
    rescue ActiveRecord::RecordInvalid
      response.headers['X-DL-Result'] = 'error'
      render partial: 'admin/shared/validation_messages',
             locals: { entity: mapping }
    rescue ActiveRecord::RecordNotUnique => e
      response.headers['X-DL-Result'] = 'error'
      render partial: 'admin/shared/validation_messages',
             locals: { entity: e }
    rescue => e
      handle_error(e)
      keep_flash
      render 'update'
    else
      response.headers['X-DL-Result'] = 'success'
      flash['success'] = 'Value mapping updated.'
      keep_flash
      render 'update' # update.js.erb will reload the page
    end

    private

    def sanitized_params
      params.require(:value_mapping).permit(PERMITTED_PARAMS)
    end

    def set_permitted_params
      @permitted_params = params.permit(PERMITTED_PARAMS)
    end

  end

end
