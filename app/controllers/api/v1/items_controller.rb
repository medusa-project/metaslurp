module Api

  module V1

    class ItemsController < ApiController

      ##
      # Responds to PUT /api/v1/items. Used for both creating and updating
      # items.
      #
      def update
        item = nil
        entity = request.body
        entity = entity.is_a?(StringIO) ? entity.string : entity.to_s
        begin
          json = JSON.parse(entity)
          item = Item.from_json(json)

          # example.org source URIs are used in testing.
          if item.source_uri.start_with?('http://example.org')
            Rails.logger.debug("Ignoring test item: #{item}")
          else
            # TODO: handle the item
            Rails.logger.info("Ingested #{item}")
          end
        rescue ArgumentError, JSON::ParserError => e
          render plain: e.message, status: :bad_request
        else
          head :no_content
        end
      end

    end

  end

end
