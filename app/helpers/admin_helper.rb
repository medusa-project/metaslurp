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

end
