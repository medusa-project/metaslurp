module ApplicationHelper

  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
      when :success
        'alert-success'
      when :error
        'alert-danger'
      when :alert
        'alert-block'
      when :notice
        'alert-info'
      else
        flash_type.to_s
    end
  end

  ##
  # @param items [Enumerable<Hash>] Hashes with optional :label, :url, :class,
  #                                 :icon, :method, and :confirm keys.
  #
  def button_bar(*items)
    html = '<div class="btn-group pull-right">'

    items.each do |item|
      options = {}
      options[:class] = 'btn ' + (item[:class].present? ? item[:class] : 'btn-default')
      if item[:method].present?
        options[:method] = item[:method]
      end
      if item[:confirm].present?
        options[:data] = { confirm: item[:confirm] }
      end

      html += link_to(item[:url], options) do
        raw((item[:icon].present? ? "<i class=\"fa #{item[:icon]}\"></i> " : ' ')) +
        item[:label]
      end
    end

    html += '</div>'
    raw(html)
  end

  ##
  # @return [String] Bootstrap alerts for each flash message.
  #
  def flashes
    html = ''
    flash.each do |type, message|
      html += "<div class=\"pt-flash alert alert-dismissable #{bootstrap_class_for(type)}\">
          <button type=\"button\" class=\"close\" data-dismiss=\"alert\"
                  aria-hidden=\"true\">&times;</button>
          #{message}
        </div>"
    end
    raw(html)
  end

end
