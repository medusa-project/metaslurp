class ContentServicesController < ApplicationController

  def index
    @services = ContentService.all.order(:name)
  end

  def show
    @service = ContentService.find_by_key(params[:key])
    raise ActiveRecord::RecordNotFound unless @service

    @num_items = @service.num_items
  end

end
