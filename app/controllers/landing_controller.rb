class LandingController < ApplicationController

  SERVICE_KEYS = [:book, :databank, :dls, :ideals, :idnc]

  def index
    @num_items = ItemFinder.new.limit(0).count
    @services = {}
    SERVICE_KEYS.each{ |k| @services[k] = ContentService.find_by_key(k) }
  end

end
