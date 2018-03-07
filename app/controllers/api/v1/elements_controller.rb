module Api

  module V1

    class ElementsController < ApiController

      ##
      # Responds to GET /api/v1/elements
      #
      def index
        @start = params[:start].to_i
        @limit = params[:limit].to_i
        @limit = DEFAULT_RESULTS_LIMIT if @limit < 1
        @limit = MAX_RESULTS_LIMIT if @limit > MAX_RESULTS_LIMIT

        @elements = Element.all.order(:index).limit(@limit).offset(@start)

        render json: {
            start: @start,
            limit: @limit,
            numResults: @count,
            results: @elements
        }
      end

    end

  end

end
