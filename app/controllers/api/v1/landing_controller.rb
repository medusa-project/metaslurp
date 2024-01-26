# frozen_string_literal: true

module Api

  module V1

    class LandingController < ApiController

      ##
      # Responds to GET /api/v1
      #
      def index
        @version_path_component = 'v1'
      end

    end

  end

end
