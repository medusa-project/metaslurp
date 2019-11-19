class HealthController < ApplicationController

  ##
  # Responds to GET /health
  #
  def index
    # touch the database
    Harvest.count

    # touch Elasticsearch
    ItemFinder.new.aggregations(false).limit(0).count

    render plain: 'OK'
  end

end
