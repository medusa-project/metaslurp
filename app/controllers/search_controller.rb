# frozen_string_literal: true

##
# Searches across items of all variants, a.k.a. everything.
#
# @see ItemsController
# @see CollectionsController
#
class SearchController < ApplicationController

  PERMITTED_PARAMS = [{ fq: [] }, :q, :sort, :start, :utf8]

  before_action :set_sanitized_params

  def index
    @start = [@permitted_params[:start].to_i.abs, max_start].min
    @limit = window_size

    relation = Item.search.
        query_all(params[:q]).
        facet_filters(params[:fq]).
        order(params[:sort]).
        include_children(true).
        start(@start).
        limit(@limit)
    @items             = relation.to_a
    @facets            = relation.facets
    @count             = relation.count
    @current_page      = relation.page
    @num_results_shown = [@limit, @count].min
    @es_request_json   = relation.request_json
    @es_response_json  = relation.response_json

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
