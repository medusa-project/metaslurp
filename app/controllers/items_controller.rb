class ItemsController < ApplicationController

  def index
    @start = params[:start] || 0
    @limit = Option::integer(Option::Keys::DEFAULT_RESULT_WINDOW)

    finder = ItemFinder.new.
        include_variants(Item::Variants::ITEM).
        start(@start).
        limit(@limit)
    @items = finder.to_a
  end

end
