##
# Favorites are saved in a cookie named "favorites".
#
class FavoritesController < WebsiteController

  COOKIE_DELIMITER = ','

  before_action :set_sanitized_params
  after_action :purge_invalid_favorites

  ##
  # Responds to GET /favorites
  #
  def index
    @items = nil
    @count = 0
    @num_results_shown = 0
    @start = params[:start] ? params[:start].to_i : 0
    @limit = Option::integer(Option::Keys::DEFAULT_RESULT_WINDOW)

    if cookies[:favorites].present?
      ids = cookies[:favorites].split(COOKIE_DELIMITER)
      if ids.any?
        finder = ItemFinder.new.
            aggregations(false).
            filter(Item::IndexFields::ID, ids).
            start(@start).
            limit(@limit)
        @items = finder.to_a
        @count = finder.count
        @num_results_shown = @items.length
      end
    end

    @current_page = (@start / @limit.to_f).ceil + 1 if @limit > 0 || 1

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  ##
  # Rewrites the favorites cookie if there are any items in the cookie that
  # no longer exist in the application.
  #
  def purge_invalid_favorites
    if @items and request.format == :html and cookies[:favorites]
      ids = cookies[:favorites].split(COOKIE_DELIMITER)
      if ids.length != @items.count
        cookies[:favorites] = @items.map(&:repository_id).join(COOKIE_DELIMITER)
      end
    end
  end

  def set_sanitized_params
    @permitted_params = params.permit(:start)
  end

end
