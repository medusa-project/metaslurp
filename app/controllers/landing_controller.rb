class LandingController < ApplicationController

  def index
    @services = ContentService.all.order(:name)
  end

end
