# frozen_string_literal: true

module Api

  module V1

    class HarvestsController < ApiController

      LOGGER = CustomLogger.new(HarvestsController)

      ##
      # Responds to POST /api/v1/harvests. Used for creating harvests.
      #
      def create
        begin
          json = request_json
          harvest = Harvest.new(user: current_user)
          harvest.update_from_json(json)
          LOGGER.debug('Created harvest %s', harvest)
        rescue ArgumentError, JSON::ParserError => e
          LOGGER.debug('%s: %s', e, request.body)
          render plain: e.message, status: :bad_request
        rescue IOError => e
          LOGGER.error(e)
          render plain: e.message, status: :internal_server_error
        else
          render json: {
              path: api_v1_harvest_path(harvest),
              key: harvest.key
          }, status: :created
        end
      end

      ##
      # Responds to `DELETE /api/v1/harvests/:key`. Used for deleting harvests.
      #
      def destroy
        begin
          harvest = Harvest.find_by_key(params[:key])
          raise ActiveRecord::RecordNotFound unless harvest
          if harvest.destroyable?
            harvest.destroy!
            head :no_content
          else
            render plain: "A running harvest cannot be deleted. Abort it first.",
                   status: :conflict
          end
        rescue ArgumentError, ActiveRecord::RecordInvalid, JSON::ParserError => e
          LOGGER.debug('Invalid: %s', json)
          render plain: e.message, status: :bad_request
        rescue IOError => e
          LOGGER.error(e)
          render plain: e.message, status: :internal_server_error
        end
      end

      ##
      # Responds to PATCH /api/v1/harvests/:key. Used for updating harvests.
      #
      def update
        begin
          harvest = Harvest.find_by_key(params[:key])
          raise ActiveRecord::RecordNotFound unless harvest
          json = request_json
          harvest.update_from_json(json)
          LOGGER.debug('Updated harvest %s', harvest)
        rescue ArgumentError, ActiveRecord::RecordInvalid, JSON::ParserError => e
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
        # API exposes `service_key` but the Harvest requires
        # `content_service_id`.
        json['content_service_id'] = ContentService.find_by_key(json['service_key'])&.id
        json
      end

    end

  end

end
