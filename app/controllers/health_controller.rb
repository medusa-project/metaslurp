class HealthController < ApplicationController

  ##
  # Responds to GET /health
  #
  def index
    # Touch the database... except in demo, where the database is running in
    # Aurora and we can save money by letting it go idle.
    Harvest.count unless Rails.env.demo?
  rescue => e
    render plain: "RED: #{e}", status: :internal_server_error
  else
    render plain: 'GREEN'
  end

end
