module ApplicationHelper

  ##
  # Formats a boolean for display.
  #
  # @param boolean [Boolean]
  # @return [String]
  #
  def boolean(boolean)
    raw(boolean ? '<span class="text-success">&check;</span>' :
            '<span class="text-danger">&times;</span>')
  end

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
  # @return [String]
  #
  def favicon_link_tags
    # https://uofi.app.box.com/v/Illinois-Logo/file/209399852568
    html = "<link rel=\"apple-touch-icon\" sizes=\"57x57\" href=\"#{image_url('apple-icon-57x57.png')}\">
    <link rel=\"apple-touch-icon\" sizes=\"60x60\" href=\"#{image_url('apple-icon-60x60.png')}\">
    <link rel=\"apple-touch-icon\" sizes=\"72x72\" href=\"#{image_url('apple-icon-72x72.png')}\">
    <link rel=\"apple-touch-icon\" sizes=\"76x76\" href=\"#{image_url('apple-icon-76x76.png')}\">
    <link rel=\"apple-touch-icon\" sizes=\"114x114\" href=\"#{image_url('apple-icon-114x114.png')}\">
    <link rel=\"apple-touch-icon\" sizes=\"120x120\" href=\"#{image_url('apple-icon-120x120.png')}\">
    <link rel=\"apple-touch-icon\" sizes=\"144x144\" href=\"#{image_url('apple-icon-144x144.png')}\">
    <link rel=\"apple-touch-icon\" sizes=\"152x152\" href=\"#{image_url('apple-icon-152x152.png')}\">
    <link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"#{image_url('apple-icon-180x180.png')}\">
    <link rel=\"icon\" type=\"image/png\" sizes=\"192x192\" href=\"#{image_url('android-icon-192x192.png')}\">
    <link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"#{image_url('favicon-32x32.png')}\">
    <link rel=\"icon\" type=\"image/png\" sizes=\"96x96\" href=\"#{image_url('favicon-96x96.png')}\">
    <link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"#{image_url('favicon-16x16.png')}\">
    <meta name=\"msapplication-TileColor\" content=\"#ffffff\">
    <meta name=\"msapplication-TileImage\" content=\"#{image_url('ms-icon-144x144.png')}\">
    <meta name=\"theme-color\" content=\"#ffffff\">"
    raw(html)
  end

  ##
  # @return [String] Bootstrap alerts for each flash message.
  #
  def flashes
    html = ''
    flash.each do |type, message|
      html += "<div class=\"dl-flash alert alert-dismissable #{bootstrap_class_for(type)}\">
          <button type=\"button\" class=\"close\" data-dismiss=\"alert\"
                  aria-hidden=\"true\">&times;</button>
          #{message}
        </div>"
    end
    raw(html)
  end

end
