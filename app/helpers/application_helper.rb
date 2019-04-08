module ApplicationHelper

  LOGGER = CustomLogger.new(ApplicationHelper)

  MAX_PAGINATION_LINKS = 7
  MAX_THUMBNAIL_SIZE = 512
  CONTENT_SERVICE_THUMBNAIL_SIZE = 4096
  THUMBNAIL_JPEG_QUALITY = 60

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
  # @param items [Enumerable<Hash>] Enumerable of hashes with :label and
  #                                 :url keys.
  # @return [String] HTML string
  #
  def breadcrumb(*items)
    html = StringIO.new
    html << '<nav aria-label="breadcrumb">'
    html <<   '<ol class="breadcrumb">'
    items.each_with_index do |item, index|
      if index < items.length - 1
        html << sprintf('<li class="breadcrumb-item"><a href="%s">%s</a></li>',
                        item[:url], item[:label])
      else
        html << sprintf('<li class="breadcrumb-item active" aria-current="page">%s</li>',
                        item[:label])
      end
    end
    html <<   '</ol>'
    html << '</nav>'
    raw(html.string)
  end

  ##
  # The argument is a list of hashes. A hash may contain any HTML attribute.
  # Also:
  #
  # * A :label key is required.
  # * If a :type key is present with a value of `button`, a button element will
  #   be rendered for it; otherwise, an anchor.
  # * If the element is an anchor, a :url key should present, corresponding to
  #   an "href" attribute.
  # * An :icon key may be present referring to a Font Awesome icon name.
  # * :method and :confirm keys are available.
  # * If an :if key is present pointing to a lambda, the item will only be
  #   added to the button bar if the lambda returns true.
  #
  # @param items [Enumerable<Hash>]
  #
  def button_bar(*items)
    html = '<div class="btn-group float-right" role="group">'

    items.select{ |item| !item[:if] or item[:if].call }.each do |item|
      options = {}
      options[:class] = 'btn ' + (item[:class].present? ? item[:class] : 'btn-light')
      item[:class] = nil
      if item[:method].present?
        options[:method] = item[:method]
        item[:method] = nil
      end
      if item[:confirm].present?
        options[:data] = { confirm: item[:confirm] }
        item[:confirm] = nil
      end

      if item[:type] == 'button'
        html += "<button type=\"button\" class=\"#{options[:class]}\" #{item.map{ |k,v| "#{k}=\"#{v}\"" }.join(' ')}>" +
            raw((item[:icon].present? ? "<i class=\"fas #{item[:icon]}\"></i> " : ' ')) +
            item[:label] + '</button>'
      else
        html += link_to(item[:url], options) do
          raw((item[:icon].present? ? "<i class=\"fas #{item[:icon]}\"></i> " : ' ')) +
          item[:label]
        end
      end
    end

    html += '</div>'
    raw(html)
  end

  ##
  # @param facets [Enumerable<Facet>]
  # @param permitted_params [ActionController::Parameters]
  # @return [String] HTML string
  #
  def facets_as_cards(facets, permitted_params)
    return nil unless facets
    html = StringIO.new
    facets.select{ |f| f.buckets.any? }.each do |facet|
      html << facet_card(facet, params.permit(permitted_params))
    end
    raw(html.string)
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
    html = StringIO.new
    flash.each do |type, message|
      html << "<div class=\"alert alert-dismissable #{bootstrap_class_for(type)}\" role=\"alert\">
          <button type=\"button\" class=\"close\" data-dismiss=\"alert\"
                  aria-label=\"Close\">
            <span aria-hidden=\"true\">&times;</span>
          </button>
          #{message}
        </div>"
    end
    raw(html.string)
  end

  ##
  # Returns the most appropriate icon for the given object. If the object is
  # unrecognized, a generic icon will be returned.
  #
  # @param entity [Object]
  # @return [String] HTML <i> tag
  #
  def icon_for(entity)
    if entity == Item
      icon = 'fa-cube'
    elsif entity.kind_of?(Item)
      case entity.variant
        when Item::Variants::BOOK
          icon = 'fa-book'
        when Item::Variants::COLLECTION
          icon = 'fa-folder-open'
        when Item::Variants::DATA_SET
          icon = 'fa-archive'
        when Item::Variants::FILE
          icon = 'fa-file'
        when Item::Variants::NEWSPAPER_PAGE
          icon = 'fa-newspaper'
        when Item::Variants::PAPER
          icon = 'fa-file-alt'
        else
          icon = 'fa-cube'
      end
    elsif entity == ContentService or entity.kind_of?(ContentService)
      icon = 'fa fa-database'
    elsif entity == User or entity.kind_of?(User)
      icon = 'fa-user'
    else
      icon = 'fa-cube'
    end
    raw("<i class=\"fas #{icon}\" aria-hidden=\"true\"></i>")
  end

  ##
  # @param total_entities [Integer]
  # @param per_page [Integer]
  # @param permitted_params [ActionController::Parameters]
  # @param current_page [Integer]
  # @param max_links [Integer] Ideally an odd number.
  #
  def paginate(total_entities, per_page, current_page, permitted_params,
               max_links = MAX_PAGINATION_LINKS)
    return '' if total_entities <= per_page
    num_pages  = (total_entities / per_page.to_f).ceil
    first_page = [1, current_page - (max_links / 2.0).floor].max
    last_page  = [first_page + max_links - 1, num_pages].min
    first_page = last_page - max_links + 1 if
        last_page - first_page < max_links and num_pages > max_links
    prev_page  = [1, current_page - 1].max
    next_page  = [last_page, current_page + 1].min
    prev_start = (prev_page - 1) * per_page
    next_start = (next_page - 1) * per_page
    last_start = (num_pages - 1) * per_page
    unless permitted_params.kind_of?(ActionController::Parameters)
      permitted_params = params.permit(permitted_params)
    end

    first_link = link_to(permitted_params.except(:start),
                         remote: true, class: 'page-link', 'aria-label': 'First') do
      raw('<span aria-hidden="true">First</span>')
    end
    prev_link = link_to(permitted_params.merge(start: prev_start),
                        remote: true,
                        class: 'page-link',
                        'aria-label': 'Previous') do
      raw('<span aria-hidden="true">&laquo;</span>')
    end
    next_link = link_to(permitted_params.merge(start: next_start),
                        remote: true,
                        class: 'page-link',
                        'aria-label': 'Next') do
      raw('<span aria-hidden="true">&raquo;</span>')
    end
    last_link = link_to(permitted_params.merge(start: last_start),
                        remote: true,
                        class: 'page-link',
                        'aria-label': 'Last') do
      raw('<span aria-hidden="true">Last</span>')
    end

    # http://getbootstrap.com/components/#pagination
    html = StringIO.new
    html << '<nav>'
    html <<   '<ul class="pagination">'
    html <<     sprintf('<li class="page-item %s">%s</li>',
                        current_page == first_page ? 'disabled' : '',
                        first_link)
    html <<     sprintf('<li class="page-item %s">%s</li>',
                        current_page == prev_page ? 'disabled' : '',
                        prev_link)

    (first_page..last_page).each do |page|
      start = (page - 1) * per_page
      page_link = link_to((start == 0) ? permitted_params.except(:start) :
                              permitted_params.merge(start: start), class: 'page-link', remote: true) do
        raw("#{page} #{(page == current_page) ?
                           '<span class="sr-only">(current)</span>' : ''}")
      end
      html << sprintf('<li class="page-item %s">%s</li>',
                      page == current_page ? 'active' : '',
                      page_link)

    end
    html << sprintf('<li class="page-item %s">%s</li>',
                    current_page == next_page ? 'disabled' : '',
                    next_link)
    html << sprintf('<li class="page-item %s">%s</li>',
                    current_page == last_page ? 'disabled' : '',
                    last_link)
    html <<   '</ul>'
    html << '</nav>'
    raw(html.string)
  end

  ##
  # @param entity [Object]
  # @param options [Hash] Options to pass to `image_tag()`
  # @return [String] HTML <img> tag
  #
  def thumbnail_for(entity, options = {})
    # SVG versions of these:
    # https://github.com/encharm/Font-Awesome-SVG-PNG/tree/master/black/svg
    if entity == Item
      icon = 'cube'
    elsif entity.kind_of?(Item)
      if entity.thumbnail_image
        return image_tag(item_image_url(entity),
                         options.merge('data-location': 'remote'))
      else
        # Fall back to a generic icon based on variant.
        case entity.variant
        when Item::Variants::BOOK
          icon = 'book'
        when Item::Variants::COLLECTION
          icon = 'folder-open-o'
        when Item::Variants::DATA_SET
          icon = 'archive'
        when Item::Variants::FILE
          icon = 'file-o'
        when Item::Variants::NEWSPAPER_PAGE
          icon = 'newspaper-o'
        when Item::Variants::PAPER
          icon = 'file-text-o'
        else
          icon = 'cube'
        end
      end
    elsif entity == ContentService or entity.kind_of?(ContentService)
      # Check for a representative image in ActiveStorage.
      if entity.representative_image.attached?
        begin
          return image_tag(entity.representative_image.variant(resize: "#{CONTENT_SERVICE_THUMBNAIL_SIZE}x#{CONTENT_SERVICE_THUMBNAIL_SIZE}",
                                                               quality: THUMBNAIL_JPEG_QUALITY,
                                                               interlace: 'plane'),
                           options.merge('data-location': 'local'))
        rescue => e
          LOGGER.error(e)
          icon = 'database'
        end
      else
        icon = 'database'
      end
    else
      icon = 'cube'
    end
    image_tag('fontawesome-' + icon + '.svg', options.merge('data-type': 'svg',
                                                            'data-location': 'local'))
  end

  ##
  # @param entity [Object]
  # @return [String] Whether the thumbnail returned by thumbnail_for() is local,
  #                  i.e. hosted within the application.
  #
  def thumbnail_is_local?(entity)
    if entity.kind_of?(Item) and entity.thumbnail_image
      return false
    end
    true
  end

  private

  ##
  # @param facet [Facet]
  #
  def facet_card(facet, permitted_params)
    panel = StringIO.new
    panel << sprintf('<div class="card dl-facet" id="%s">', facet.field)
    panel << '<h5 class="card-header">'
    panel <<   facet.name
    panel << '</h5>'
    panel << '<div class="card-body">'
    panel << '<ul>'

    facet.buckets.each do |bucket|
      checked          = params[:fq]&.include?(bucket.query) ? 'checked' : nil
      checked_params   = bucket.removed_from_params(permitted_params.deep_dup).except(:start)
      unchecked_params = bucket.added_to_params(permitted_params.deep_dup).except(:start)
      term_label       = truncate(bucket.label, length: 80)

      panel << '<li class="dl-term">'
      panel <<   '<div class="checkbox">'
      panel <<     '<label>'
      panel <<       sprintf('<input type="checkbox" name="fq[]" %s '\
                             'data-query="%s" data-checked-href="%s" '\
                             'data-unchecked-href="%s" value="%s"> ',
                             checked,
                             bucket.query.gsub('"', '&quot;'),
                             url_for(unchecked_params),
                             url_for(checked_params),
                             bucket.query)
      panel <<       term_label
      panel <<       sprintf(' <span class="dl-count">%s</span>', bucket.count)
      panel <<     '</label>'
      panel <<   '</div>'
      panel << '</li>'
    end
    panel <<     '</ul>'
    panel <<   '</div>'
    panel << '</div>'
    raw(panel.string)
  end

end
