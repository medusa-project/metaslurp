class ElementsController < ApplicationController

  protect_from_forgery with: :null_session

  ##
  # Responds to GET /elements (JSON only)
  #
  def index
    render json: ElementDef.all.order(:name).map { |e|
      {
          name: e.name,
          label: e.label,
          data_type: ElementDef::DataType::to_s(e.data_type),
          searchable: e.searchable,
          sortable: e.sortable,
          facetable: e.facetable
      }
    }
  end

end
