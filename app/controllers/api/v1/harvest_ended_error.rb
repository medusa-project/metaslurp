module Api

  module V1

    class HarvestEndedError < RuntimeError

      def http_status
        480
      end

      def message
        'This harvest has ended and is no longer available for use.'
      end

    end

  end

end
