module Admin

  class ItemsController < ControlPanelController

    def show
      @item = Item.find(params[:id])
      @indexed_document = Item.fetch_indexed_json(@item.id)
    end

  end

end
