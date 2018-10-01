class ItemsController < ApplicationController

  PERMITTED_PARAMS = [:df, { fq: [] }, :id, :q, :sort, :start]

  before_action :set_sanitized_params

  ##
  # Returns one of an item's images from a remote HTTP server.
  #
  # * Remote HTTP images are streamed through (in order to serve them via
  #   HTTPS).
  # * The client is redirected to remote HTTPS images via HTTP 303.
  #
  # Responds to GET /items/:item_id/image
  #
  def image
    item = Item.find(params[:item_id])
    image = item.thumbnail_image
    if image
      uri = URI(image.uri)
      if uri.scheme == 'http'
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri)

        http.request(request) do |response|
          send_data response.read_body,
                    disposition: 'inline',
                    filename: 'image.jpg'
        end
      else
        redirect_to image.uri, status: :see_other
      end
    else
      render plain: 'Not Found', status: :not_found
    end
  end

  ##
  # Responds to GET /items
  #
  def index
    @start = params[:start]&.to_i || 0
    @limit = Option::integer(Option::Keys::DEFAULT_RESULT_WINDOW)

    finder = ItemFinder.new.
        query_all(params[:q]).
        facet_filters(params[:fq]).
        exclude_variants(Item::Variants::COLLECTION).
        order(params[:sort]).
        start(@start).
        limit(@limit)
    @items = finder.to_a
    @facets = finder.facets
    @count = finder.count
    @current_page = finder.page
    @num_results_shown = [@limit, @count].min

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def set_sanitized_params
    @permitted_params = params.permit(PERMITTED_PARAMS)
  end

end
