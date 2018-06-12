module Api

  module V1

    class ItemsController < ApiController

      ##
      # Responds to PUT /api/v1/items. Used for both creating and updating
      # items.
      #
      def update
        begin
          json = request_json
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
        rescue HarvestAbortedError => e
          render plain: e.message, status: e.http_status
        rescue HarvestEndedError => e
          render plain: e.message, status: e.http_status
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

      private

      def request_json
        entity = request.body
        entity = entity.is_a?(StringIO) ? entity.string : entity.to_s

        json = JSON.parse(entity)

        # Validate the harvest key
        harvest = Harvest.find_by_key(json['harvest_key'])
        raise ArgumentError, 'Invalid harvest key' unless harvest

        # Validate the harvest status
        case harvest.status
          when Harvest::Status::ABORTED
            raise HarvestAbortedError
          when Harvest::Status::SUCCEEDED, Harvest::Status::FAILED
            raise HarvestEndedError
        end

        json['service_key'] = harvest.content_service.key
        json
      end

    end

  end

end
