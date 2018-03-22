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

          # Test items have example.org source URIs. Discard them without
          # raising any errors.
          if item.source_uri.start_with?('http://example.org')
            Rails.logger.debug("Ignoring test item: #{item}")
          else
            item.content_service.update_element_mappings(item.elements)
            item.save!
            Rails.logger.debug("Ingested #{item}: #{json}")
          end
        rescue ArgumentError, JSON::ParserError => e
          Rails.logger.debug("Invalid: #{json}")
          render plain: e.message, status: :bad_request
        rescue IOError => e
          Rails.logger.error("#{e}")
          render plain: e.message, status: :internal_server_error
        else
          head :no_content
        end
      end

    end

  end

end
