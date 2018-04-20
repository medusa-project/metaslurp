##
# Searches across items of all variants, a.k.a. everything.
#
class SearchController < ApplicationController

  PERMITTED_PARAMS = [{ fq: [] }, :q, :sort, :start, :utf8]

  before_action :set_sanitized_params

  def index
    @start = params[:start]&.to_i || 0
    @limit = Option::integer(Option::Keys::DEFAULT_RESULT_WINDOW)

    finder = ItemFinder.new.
        query_all(params[:q]).
        facet_filters(params[:fq]).
        order(params[:sort]).
        start(@start).
        limit(@limit)
    @items = finder.to_a
    @facets = finder.facets
    @count = finder.count
    @current_page = finder.page
    @num_results_shown = [@limit, @count].min

    respond_to do |format|
      format.html { render 'items/index' }
      format.js { render 'items/index' }
    end
  end

  private

  def set_sanitized_params
    @permitted_params = params.permit(PERMITTED_PARAMS)
  end

end
