module Admin

  class ItemsController < ControlPanelController

    before_action :load_item

    ##
    # Purges any images relating to the item from the image server's cache.
    #
    # Responds to `PATCH /admin/items/:id/purge-cached-images` (XHR only)
    #
    def purge_cached_item_images
      begin
        @item.purge_cached_images
      rescue => e
        handle_error(e)
      else
        flash['success'] = 'All cached images associated with this item have '\
                           'been purged.'
      ensure
        redirect_back fallback_location: admin_item_path(@item)
      end
    end

    ##
    # Responds to `GET /admin/items/:id`
    #
    def show
      @indexed_document = Item.fetch_indexed_json(@item.id)
      @boosts           = Boost.all
    end


    private

    def load_item
      @item = Item.find(params[:id] || params[:item_id])
    end

  end

end
