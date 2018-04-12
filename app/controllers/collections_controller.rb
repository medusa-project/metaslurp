class CollectionsController < ApplicationController

  PERMITTED_PARAMS = []

  before_action :set_sanitized_params

  def index
    @start = params[:start]&.to_i || 0
    @limit = Option::integer(Option::Keys::DEFAULT_RESULT_WINDOW)

    finder = ItemFinder.new.
        query_all(params[:q]).
        facet_filters(params[:fq]).
        include_variants(Item::Variants::COLLECTION).
        order(Element.new(name: 'title').indexed_sort_field). # TODO: this is ugly
        start(@start).
        limit(@limit)
    @items = finder.to_a
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
