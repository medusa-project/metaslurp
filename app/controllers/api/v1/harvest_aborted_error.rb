# frozen_string_literal: true

module Api

  module V1

    class HarvestAbortedError < HarvestEndedError

      def http_status
        481
      end

      def message
        'This harvest has been aborted and is is no longer available for use.'
      end

    end

  end

end
