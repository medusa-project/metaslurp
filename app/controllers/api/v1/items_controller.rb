module Api

  module V1

    class ItemsController < ApiController

      LOGGER = CustomLogger.new(ItemsController)

      ##
      # Used for both creating and updating items. Responds to
      # `PUT /api/v1/items`.
      #
      def update
        begin
          json = request_json
          item = Item.from_json(json)

          # Test items have example.org source URIs. Discard them without
          # raising any errors.
          if item.source_uri.start_with?('http://example.org')
            LOGGER.debug('Ignoring test item: %s', item)
          else
            item.save!(json['index'])
            # Doing these tasks asynchronously will enable us to return sooner,
            # which may speed up a harvest.
            UpdateElementMappingsJob.perform_later(item.id)
            PurgeCachedItemImagesJob.perform_later(item.id)
            # we don't have an image server in test
            if Rails.env.demo? || Rails.env.production?
              PurgeCachedItemImagesJob.new.perform_later(item.id)
            end
            LOGGER.debug('Ingested %s: %s', item, json)
          end
        rescue HarvestAbortedError => e
          render plain: e.message, status: e.http_status
        rescue HarvestEndedError => e
          render plain: e.message, status: e.http_status
        rescue ArgumentError, JSON::ParserError => e
          LOGGER.debug('Invalid: %s', json)
          render plain: e.message, status: :bad_request
        rescue IOError => e
          LOGGER.error(e)
          render plain: e.message, status: :internal_server_error
        else
          head :no_content
        end
      end

      private

      def request_json
        entity = request_body_string
        json   = JSON.parse(entity)

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
