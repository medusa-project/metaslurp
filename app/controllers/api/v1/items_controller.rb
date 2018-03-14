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
            service = item.content_service
            update_content_service_element_mappings(service, item.elements)

            # TODO: index the item
            Rails.logger.debug("Ingested #{item}: #{json}")
          end
        rescue ArgumentError, JSON::ParserError => e
          Rails.logger.debug("Invalid: #{json}")
          render plain: e.message, status: :bad_request
        else
          head :no_content
        end
      end

      private

      def update_content_service_element_mappings(service, item_elements)
        if item_elements.any?
          mappings = service.element_mappings

          item_elements.each do |element|
            if mappings.select { |m| m.source_name == element.name }.empty?
              mappings.build(source_name: element.name)
            end
          end
          service.save!
        end
      end

    end

  end

end
