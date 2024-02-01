# frozen_string_literal: true

##
# Searches items of Collection variant.
#
# @see ItemsController
# @see SearchController
#
class CollectionsController < ApplicationController

  PERMITTED_PARAMS = [:df, { fq: [] }, :id, :q, :sort, :start]

  before_action :set_permitted_params

  def index
    @start = [@permitted_params[:start].to_i.abs, max_start].min
    @limit = window_size

    relation = Item.search.
        query_all(params[:q]).
        facet_filters(params[:fq]).
        include_variants(Item::Variants::COLLECTION).
        order(ElementDef.new(name: 'title').indexed_sort_field).
        start(@start).
        limit(@limit)
    @items             = relation.to_a
    @facets            = relation.facets
    @count             = relation.count
    @current_page      = relation.page
    @num_results_shown = [@limit, @count].min
    @es_request_json   = relation.request_json
    @es_response_json  = relation.response_json
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

  def set_permitted_params
    @permitted_params = params.permit(PERMITTED_PARAMS)
  end

end
