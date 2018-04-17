module ApplicationHelper

  MAX_PAGINATION_LINKS = 9

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
    html = '<nav aria-label="breadcrumb">'\
      '<ol class="breadcrumb">'
    items.each_with_index do |item, index|
      if index < items.length - 1
        html += "<li class=\"breadcrumb-item\"><a href=\"#{item[:url]}\">#{item[:label]}</a></li>"
      else
        html += "<li class=\"breadcrumb-item active\" aria-current=\"page\">#{item[:label]}</li>"
      end
    end
    html += '</ol></nav>'
    raw(html)
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
    html = '<div class="btn-group pull-right" role="group">'

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
            raw((item[:icon].present? ? "<i class=\"fa #{item[:icon]}\"></i> " : ' ')) +
            item[:label] + '</button>'
      else
        html += link_to(item[:url], options) do
          raw((item[:icon].present? ? "<i class=\"fa #{item[:icon]}\"></i> " : ' ')) +
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
    html = ''
    facets.select{ |f| f.buckets.any? }.each do |facet|
      html += facet_card(facet, params.permit(permitted_params))
    end
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

  ##
  # @param total_entities [Integer]
  # @param per_page [Integer]
  # @param permitted_params [ActionController::Parameters]
  # @param current_page [Integer]
  # @param remote [Boolean]
  # @param max_links [Integer] Ideally an odd number.
  #
  def paginate(total_entities, per_page, current_page, permitted_params,
               remote = false, max_links = MAX_PAGINATION_LINKS)
    return '' if total_entities <= per_page
    num_pages = (total_entities / per_page.to_f).ceil
    first_page = [1, current_page - (max_links / 2.0).floor].max
    last_page = [first_page + max_links - 1, num_pages].min
    first_page = last_page - max_links + 1 if
        last_page - first_page < max_links and num_pages > max_links
    prev_page = [1, current_page - 1].max
    next_page = [last_page, current_page + 1].min
    prev_start = (prev_page - 1) * per_page
    next_start = (next_page - 1) * per_page
    last_start = (num_pages - 1) * per_page

    first_link = link_to(permitted_params.except(:start),
                         remote: remote, class: 'page-link', 'aria-label': 'First') do
      raw('<span aria-hidden="true">First</span>')
    end
    prev_link = link_to(permitted_params.merge(start: prev_start),
                        remote: remote,
                        class: 'page-link',
                        'aria-label': 'Previous') do
      raw('<span aria-hidden="true">&laquo;</span>')
    end
    next_link = link_to(permitted_params.merge(start: next_start),
                        remote: remote,
                        class: 'page-link',
                        'aria-label': 'Next') do
      raw('<span aria-hidden="true">&raquo;</span>')
    end
    last_link = link_to(permitted_params.merge(start: last_start),
                        remote: remote,
                        class: 'page-link',
                        'aria-label': 'Last') do
      raw('<span aria-hidden="true">Last</span>')
    end

    # http://getbootstrap.com/components/#pagination
    html = '<nav>' +
        '<ul class="pagination">' +
          "<li class=\"page-item #{current_page == first_page ? 'disabled' : ''}\">#{first_link}</li>" +
          "<li class=\"page-item #{current_page == prev_page ? 'disabled' : ''}\">#{prev_link}</li>"
    (first_page..last_page).each do |page|
      start = (page - 1) * per_page
      page_link = link_to((start == 0) ? permitted_params.except(:start) :
                              permitted_params.merge(start: start), class: 'page-link', remote: remote) do
        raw("#{page} #{(page == current_page) ?
            '<span class="sr-only">(current)</span>' : ''}")
      end
      html += "<li class=\"page-item #{page == current_page ? 'active' : ''}\">" +
          page_link + '</li>'
    end
    html += "<li class=\"page-item #{current_page == next_page ? 'disabled' : ''}\">#{next_link}</li>" +
        "<li class=\"page-item #{current_page == last_page ? 'disabled' : ''}\">#{last_link}</li>"
    html += '</ul>' +
        '</nav>'
    raw(html)
  end

  private

  ##
  # @param facet [Facet]
  #
  def facet_card(facet, permitted_params)
    panel = "<div class=\"card dl-facet\" id=\"#{facet.field}\">
      <h5 class=\"card-header\">
        #{facet.name}
      </h5>
      <div class=\"card-body\">
        <ul>"
    facet.buckets.each do |bucket|
      checked = params[:fq]&.include?(bucket.query) ? 'checked' : nil
      checked_params = bucket.removed_from_params(permitted_params.deep_dup).except(:start)
      unchecked_params = bucket.added_to_params(permitted_params.deep_dup).except(:start)
      term_label = truncate(bucket.label, length: 80)

      panel += "<li class=\"dl-term\">"\
               "  <div class=\"checkbox\">"\
               "    <label>"\
               "      <input type=\"checkbox\" name=\"dl-facet-term\" #{checked} "\
               "          data-query=\"#{bucket.query.gsub('"', '&quot;')}\" "\
               "          data-checked-href=\"#{url_for(unchecked_params)}\" "\
               "          data-unchecked-href=\"#{url_for(checked_params)}\">"\
               "      #{term_label} "\
               "      <span class=\"dl-count\">#{bucket.count}</span>"\
               "    </label>"\
               "  </div>"\
               "</li>"
    end
    raw(panel + '</ul></div></div>')
  end

end
