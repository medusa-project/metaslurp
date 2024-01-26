# frozen_string_literal: true

module AdminHelper

  ##
  # @param status [Integer] One of the Harvest::Status constant values.
  # @return [String] HTML span element.
  #
  def harvest_status_badge(status)
    case status
      when Harvest::Status::NEW
        class_ = 'badge-light'
      when Harvest::Status::RUNNING
        class_ = 'badge-primary'
      when Harvest::Status::ABORTED
        class_ = 'badge-secondary'
      when Harvest::Status::SUCCEEDED
        class_ = 'badge-success'
      when Harvest::Status::FAILED
        class_ = 'badge-danger'
      else
        class_ = 'badge-info'
    end
    raw("<span class=\"badge #{class_}\">#{Harvest::Status::to_s(status)}</span>")
  end

  ##
  # @param harvest [Harvest]
  # @param options [Hash]
  # @option options [Boolean] :no_js
  # @return [String]
  #
  def harvest_title(harvest, options = {})
    title = ''
    service = harvest.content_service
    if service
      title += service.name
    else
      title += harvest.content_service.key
    end
    datetime = options[:no_js] ?
        harvest.created_at.to_s : local_time(harvest.created_at)
    raw(title + ' ' + datetime)
  end

end
