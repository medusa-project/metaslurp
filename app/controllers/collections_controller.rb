##
# Searches items of Collection variant.
#
# @see ItemsController
# @see SearchController
#
class CollectionsController < ApplicationController

  PERMITTED_PARAMS = [:df, { fq: [] }, :id, :q, :sort, :start]

  before_action :set_sanitized_params

  def index
    @start = params[:start]&.to_i || 0
    @limit = Option::integer(Option::Keys::DEFAULT_RESULT_WINDOW)

    finder = ItemFinder.new.
        query_all(params[:q]).
        facet_filters(params[:fq]).
        include_variants(Item::Variants::COLLECTION).
        order(ElementDef.new(name: 'title').indexed_sort_field).
        start(@start).
        limit(@limit)
    @items             = finder.to_a
    @facets            = finder.facets
    @count             = finder.count
    @current_page      = finder.page
    @num_results_shown = [@limit, @count].min
    @es_request_json   = finder.request_json
    @es_response_json  = finder.response_json
  end

  def show
    @item = Item.find(params[:id])
    if @item.variant != Item::Variants::COLLECTION
      raise ArgumentError, 'This item is not a collection.'
    end
    @content_service = @item.content_service
    if @content_service.key == 'mc'
      @content_service = ContentService.find_by_key('dls')
    end
  end

  private

  def set_sanitized_params
    @permitted_params = params.permit(PERMITTED_PARAMS)
  end

end
