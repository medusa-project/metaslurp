class ContentServicesController < ApplicationController

  def index
    @services = ContentService.all.order(:name)
  end

  def show
    @service = ContentService.find_by_key(params[:key])
    raise ActiveRecord::RecordNotFound unless @service

    finder = ItemFinder.new.content_service(@service)
    @num_items = finder.count
  end

end
