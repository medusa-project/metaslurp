# frozen_string_literal: true

module Admin

  class ElementDefsController < ControlPanelController

    include ActionController::Live

    class ImportMode
      MERGE   = 'merge'
      REPLACE = 'replace'
    end

    NEWLINE = "\n"
    PERMITTED_PARAMS = [:data_type, :description, :facet_order, :facetable,
                        :label, :name, :searchable, :sortable, :weight]

    before_action :require_admin, except: :index
    before_action :set_element_def, except: [:create, :import, :index]

    ##
    # Responds to `POST /admin/elements` (XHR only)
    #
    def create
      @element_def = ElementDef.new(permitted_params)
      @element_def.save!
    rescue ActiveRecord::RecordInvalid
      response.headers['X-DL-Result'] = 'error'
      render partial: 'admin/shared/validation_messages',
             locals: { entity: @element_def }
    rescue => e
      handle_error(e)
      keep_flash
      render 'create'
    else
      response.headers['X-DL-Result'] = 'success'
      flash['success'] = "Element \"#{@element_def.name}\" created."
      keep_flash
      render 'create' # create.js.erb will reload the page
    end

    ##
    # Responds to `DELETE /admin/elements/:name`
    #
    def destroy
      @element_def.destroy!
    rescue => e
      handle_error(e)
    else
      flash['success'] = "Element \"#{@element_def.name}\" deleted."
    ensure
      redirect_back fallback_location: admin_element_defs_path
    end

    ##
    # Responds to `GET /admin/elements/:name/edit` (XHR only)
    #
    def edit
      render partial: 'admin/element_defs/form',
             locals: { element_def: @element_def }
    end

    ##
    # Responds to `POST /admin/elements/import`
    #
    def import
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

    ##
    # Responds to `GET /admin/elements`
    #
    def index
      @element_defs = ElementDef.all.order(params[:sort] || :name)

      respond_to do |format|
        format.html do
          @new_element_def = ElementDef.new
        end
        format.json do
          headers['Content-Disposition'] = 'attachment; filename=elements.json'
          render plain: JSON.pretty_generate(@element_defs.as_json)
        end
      end
    end

    ##
    # Responds to `GET /admin/elements/:name`
    #
    def show
      @value_mappings = @element_def.value_mappings.order(:source_value)
      @num_usages     = ElementRelation.new(@element_def).limit(0).count
    end

    ##
    # Responds to `PATCH /admin/elements/:name` (XHR only)
    #
    def update
      @element_def.update!(permitted_params)
    rescue ActiveRecord::RecordInvalid
      response.headers['X-DL-Result'] = 'error'
      render partial: 'admin/shared/validation_messages',
             locals: { entity: @element_def }
    rescue => e
      handle_error(e)
      keep_flash
      render 'update'
    else
      flash['success'] = "Element \"#{@element_def.name}\" updated."
      keep_flash
      render 'update' # update.js.erb will reload the page
    end

    ##
    # Responds to `GET /admin/elements/:name/usages`
    #
    def usages
      response.header['Content-Type'] = 'text/tab-separated-values'
      response.header['Content-Disposition'] = "attachment; filename=\"#{@element_def.name}.tsv\""
      response.stream.write ElementRelation::TSV_HEADER
      response.stream.write NEWLINE

      offset = 0
      limit  = 1000
      rows   = [:placeholder]
      while rows.any?
        relation = ElementRelation.new(@element_def)
        if params[:content_service_key].present?
          content_service = ContentService.find_by_key(params[:content_service_key])
          relation = relation.content_service(content_service)
        end
        rows = relation.start(offset).limit(limit).to_a
            .map{ |o| o.values.map{ |v| v.gsub("\t", "") }.join("\t") }
        response.stream.write rows.join(NEWLINE)
        response.stream.write NEWLINE
        offset += limit
      end
    ensure
      response.stream.close
    end


    private

    def permitted_params
      params.require(:element_def).permit(PERMITTED_PARAMS)
    end

    def set_element_def
      @element_def = ElementDef.find_by_name(params[:name] || params[:element_def_name])
      raise ActiveRecord::RecordNotFound unless @element_def
    end

  end

end
