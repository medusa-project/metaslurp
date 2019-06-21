module Admin

  class ElementDefsController < ControlPanelController

    include ActionController::Live

    class ImportMode
      MERGE = 'merge'
      REPLACE = 'replace'
    end

    NEWLINE = "\n"
    PERMITTED_PARAMS = [:data_type, :description, :facetable, :label, :name,
                        :searchable, :sortable, :weight]

    before_action :set_permitted_params
    before_action :require_admin, except: :index

    ##
    # Responds to POST /admin/elements (XHR only)
    #
    def create
      @element = ElementDef.new(sanitized_params)
      begin
        @element.save!
      rescue ActiveRecord::RecordInvalid
        response.headers['X-DL-Result'] = 'error'
        render partial: 'shared/validation_messages',
               locals: { entity: @element }
      rescue => e
        handle_error(e)
        keep_flash
        render 'create'
      else
        response.headers['X-DL-Result'] = 'success'
        flash['success'] = "Element \"#{@element.name}\" created."
        keep_flash
        render 'create' # create.js.erb will reload the page
      end
    end

    ##
    # Responds to DELETE /admin/elements/:name
    def destroy
      element = ElementDef.find_by_name(params[:name])
      raise ActiveRecord::RecordNotFound unless element
      begin
        element.destroy!
      rescue => e
        handle_error(e)
      else
        flash['success'] = "Element \"#{element.name}\" deleted."
      ensure
        redirect_back fallback_location: admin_element_defs_path
      end
    end

    ##
    # Responds to GET /admin/elements/:name/edit (XHR only)
    #
    def edit
      element_def = ElementDef.find_by_name(params[:name])
      raise ActiveRecord::RecordNotFound unless element_def

      render partial: 'admin/element_defs/form',
             locals: { element_def: element_def, context: :edit }
    end

    ##
    # Responds to POST /admin/elements/import
    #
    def import
      begin
        raise 'No elements specified.' if params[:elements].blank?

        json = params[:elements].read.force_encoding('UTF-8')
        struct = JSON.parse(json)
        ActiveRecord::Base.transaction do
          if params[:import_mode] == ImportMode::REPLACE
            ElementDef.delete_all # skip callbacks & validation
          end
          struct.each do |hash|
            e = ElementDef.find_by_name(hash['name'])
            if e
              e.update_from_json_struct(hash)
            else
              ElementDef.from_json_struct(hash).save!
            end
          end
        end
      rescue => e
        handle_error(e)
        redirect_to admin_element_defs_path
      else
        flash['success'] = "#{struct.length} elements created or updated."
        redirect_to admin_element_defs_path
      end
    end

    ##
    # Responds to GET /admin/elements
    #
    def index
      @elements = ElementDef.all.order(:name)

      respond_to do |format|
        format.html do
          @new_element_def = ElementDef.new
        end
        format.json do
          headers['Content-Disposition'] = 'attachment; filename=elements.json'
          render plain: JSON.pretty_generate(@elements.as_json)
        end
      end
    end

    ##
    # Responds to GET /admin/elements/:name
    #
    def show
      @element = ElementDef.find_by_name(params[:name])
      raise ActiveRecord::RecordNotFound unless @element

      @num_usages = ElementFinder.new(@element).limit(0).count
    end

    ##
    # Responds to PATCH /admin/elements/:name (XHR only)
    #
    def update
      element = ElementDef.find_by_name(params[:name])
      raise ActiveRecord::RecordNotFound unless element

      begin
        element.update!(sanitized_params)
      rescue ActiveRecord::RecordInvalid
        response.headers['X-DL-Result'] = 'error'
        render partial: 'admin/shared/validation_messages',
               locals: { entity: element }
      rescue => e
        handle_error(e)
        keep_flash
        render 'update'
      else
        flash['success'] = "Element \"#{element.name}\" updated."
        keep_flash
        render 'update' # update.js.erb will reload the page
      end
    end

    ##
    # Responds to GET /admin/elements/:name/usages
    #
    def usages
      element = ElementDef.find_by_name(params[:element_def_name])
      raise ActiveRecord::RecordNotFound unless element

      response.header['Content-Type'] = 'text/tab-separated-values'
      response.header['Content-Disposition'] = "attachment; filename=\"#{element.name}.tsv\""
      response.stream.write ElementFinder::TSV_HEADER
      response.stream.write NEWLINE

      offset = 0
      limit  = 1000
      rows   = [:placeholder]
      while rows.any?
        finder = ElementFinder.new(element)
        if params[:content_service_key].present?
          content_service = ContentService.find_by_key(params[:content_service_key])
          finder = finder.content_service(content_service)
        end

        rows = finder.start(offset).limit(limit).to_a
            .map{ |o| o.values.map{ |v| v.gsub("\t", "") }.join("\t") }
        response.stream.write rows.join(NEWLINE)
        response.stream.write NEWLINE
        offset += limit
      end
    ensure
      response.stream.close
    end

    private

    def sanitized_params
      params.require(:element_def).permit(PERMITTED_PARAMS)
    end

    def set_permitted_params
      @permitted_params = params.permit(PERMITTED_PARAMS)
    end

  end

end
