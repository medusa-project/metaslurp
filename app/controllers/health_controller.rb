class HealthController < ApplicationController

  ##
  # Responds to GET /health
  #
  def index
    # Touch the database... except in demo, where the database is running in
    # Aurora and costs nothing during idle periods.
    Harvest.count unless Rails.env.demo?

    # touch Elasticsearch
    ItemFinder.new.aggregations(false).limit(0).count

    render plain: 'OK'
  end

end
