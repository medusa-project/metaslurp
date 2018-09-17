module Admin

  class StatusController < ControlPanelController

    ##
    # Responds to GET /admin/status
    #
    def status
      @es_stats = ElasticsearchClient.instance.jvm_statistics
    end

  end

end