module AdminHelper

  ##
  # @param option_keys [Enumerable<Hash<String,String>>] Enumerable of hashes
  #                    with :label, :key, and :type keys.
  # @return [String] HTML table element.
  #
  def admin_configuration_table_for(*option_keys)
    html = '<table class="table">'
    option_keys.each do |key|
      html += '<tr><td>'
      html += label_tag("configuration[#{key[:key]}]", key[:label])
      html += '</td><td>'
      case key[:type]
        when :number
          html += number_field_tag("configuration[#{key[:key]}]",
                                   Option::string(key[:key]),
                                   class: 'form-control')
        when :textarea
          html += text_area_tag("configuration[#{key[:key]}]",
                                 Option::string(key[:key]),
                                 class: 'form-control')
        else
          html += text_field_tag("configuration[#{key[:key]}]",
                                 Option::string(key[:key]),
                                 class: 'form-control')
      end
      html += '</td></tr>'
    end
    html += '</table>'
    raw(html)
  end

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
