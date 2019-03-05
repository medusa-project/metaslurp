class LandingController < ApplicationController

  def index
    Rails.logger.error('LandingController.index()')
    @services = ContentService.all.order(:name)
  end

end
