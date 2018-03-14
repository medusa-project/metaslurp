module Api

  module V1

    class ItemsController < ApiController

      ##
      # Responds to PUT /api/v1/items. Used for both creating and updating
      # items.
      #
      def update
        id = params[:id]

        entity = request.body
        entity = entity.is_a?(StringIO) ? entity.string : entity.to_s
        begin
          json = JSON.parse(entity)
          Item.from_json(json)
        rescue ArgumentError, JSON::ParserError => e
          render plain: e.message, status: :bad_request
        else
          Rails.logger.info("Ingested #{id}")
          head :no_content
        end
      end

    end

  end

end
