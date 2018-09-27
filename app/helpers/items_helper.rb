module ItemsHelper

  MAX_MEDIA_TITLE_LENGTH = 120
  MAX_MEDIA_DESCRIPTION_LENGTH = 200

  ##
  # Renders the given items as a series of
  # [Bootstrap media objects](https://getbootstrap.com/docs/4.0/layout/media-object/).
  #
  # @param items [Enumerable<Item>]
  # @param options [Hash]
  # @option options [Boolean] :link_to_admin
  # @return [String] HTML string
  #
  def items_as_media(items, options = {})
    html = '<ul class="list-unstyled">'

    items.each do |item|
      title = raw(StringUtils.truncate(item.title, MAX_MEDIA_TITLE_LENGTH))
      desc = raw(StringUtils.truncate(item.description, MAX_MEDIA_DESCRIPTION_LENGTH))

      html += '<li class="media my-4">'
      html +=     link_to(item.source_uri) do
        thumbnail_for(item,
                      class: 'mr-3',
                      alt: "Thumbnail for #{item}")
      end
      html +=   '<div class="media-body">'
      html +=     '<h5 class="mt-0">'
      if options[:link_to_admin]
        html += link_to(title, admin_item_path(item), target: '_blank')
      else
        html += title
      end
      if item.date
        html +=       " <small>#{item.date.year}</small>"
      end
      html +=     '</h5>'
      # Display the currently sorted element value, if not date or title (which
      # are already visible), on its own line:
      # https://bugs.library.illinois.edu/browse/DLDS-45
      sorted_element = ElementDef.all.find{ |e| e.indexed_sort_field == params[:sort] }
      if sorted_element
        exclude_elements = %w(date title)
        el = item.elements
                 .reject{ |e| exclude_elements.include?(e.name) }
                 .find{ |e| e.name == sorted_element.name }
        html +=   "#{sorted_element.label}: #{el.value}<br>" if el
      end

      # Info line (beneath title)
      html +=     '<span class="dl-info-line">'
      html +=       icon_for(item) + ' '
      html +=       item.variant.underscore.humanize.split(' ').map(&:capitalize).join(' ')

      ht_url = item.element(:hathiTrustURL) # only Book Tracker items will have this
      if ht_url
        html +=       ' | '
        html += link_to ht_url.value do
          raw(" <i class=\"fas fa-external-link-alt\"></i> HathiTrust ")
        end
      end

      ia_url = item.element(:internetArchiveURL) # only Book Tracker items will have this
      if ia_url
        html +=       ' | '
        html += link_to ia_url.value do
          raw(" <i class=\"fas fa-external-link-alt\"></i> Internet Archive ")
        end
      end

      catalog_url = item.element(:uiucCatalogURL) # only Book Tracker items will have this
      if catalog_url
        html +=       ' | '
        html += link_to "#{catalog_url.value.chomp('/Description')}/Description" do
          raw(" <i class=\"fas fa-external-link-alt\"></i> Library Catalog ")
        end
      end

      if !ht_url and !ia_url and !catalog_url
        html +=       ' | '

        uri = item.source_uri
        # If the item is from IDNC/Veridian, append the search query in order
        # to make it appear highlighted on the page.
        if item.content_service.key == 'idnc' and params[:q].present?
          uri += "&e=-------en-20--1--txt-txIN-#{CGI::escape(params[:q])}-------"
        end

        html += link_to uri do
          raw(" <i class=\"fas fa-external-link-alt\"></i> #{item.content_service.name} ")
        end
      end

      html +=         remove_from_favorites_button(item)
      html +=         ' ' + add_to_favorites_button(item)
      html +=     '</span><br>'
      html +=     desc if desc.present?
      html +=   '</div>'
      html += '</li>'
    end

    html += '</ul>'
    raw(html)
  end

  ##
  # @return [Integer]
  #
  def num_favorites
    cookies[:favorites] ?
        cookies[:favorites].split(FavoritesController::COOKIE_DELIMITER).length : 0
  end

  ##
  # Returns the status of a search or browse action, e.g. "Showing n of n
  # items".
  #
  # @param total_num_results [Integer]
  # @param start [Integer]
  # @param num_results_shown [Integer]
  # @return [String]
  #
  def search_status(total_num_results, start, num_results_shown, word)
    last = [total_num_results, start + num_results_shown].min
    raw(sprintf('Showing %s&ndash;%s of %s %s',
                number_with_delimiter(start + 1),
                number_with_delimiter(last),
                number_with_delimiter(total_num_results),
                word.pluralize(total_num_results)))
  end

  ##
  # Returns a pulldown menu for choosing an element to sort on. If there are
  # no sortable elements, a zero-length string is returned.
  #
  # @return [String] HTML select element
  #
  def sort_menu
    sortable_elements = ElementDef.where(sortable: true).order(:name)
    html = ''
    if sortable_elements.any?
      html += '<select name="sort" class="custom-select my-1 mr-sm-2">
          <optgroup label="Sort by&hellip;">'
      html += "<option value=\"\">#{params[:q].present? ? 'Relevance' : 'Default Order'}</option>"

      # If there is an element in the ?sort= query, select it.
      selected_element = sortable_elements.
          select{ |e| e.indexed_sort_field == params[:sort] }.first
      sortable_elements.each do |e|
        selected = (e == selected_element) ? 'selected' : ''
        html += "<option value=\"#{e.indexed_sort_field}\" #{selected}>#{e.label}</option>"
      end
      html += '</optgroup>
          </select>'
    end
    raw(html)
  end

  private

  ##
  # @param item [Item]
  # @return [String] HTML <button> element
  #
  def add_to_favorites_button(item)
    html = '<button class="btn btn-light btn-sm ' +
        'dl-add-to-favorites" data-item-id="' + item.id + '">'
    html += '  <i class="far fa-heart"></i>'
    html += '</button>'
    raw(html)
  end

  ##
  # @param item [Item]
  # @return [String] HTML <button> element
  #
  def remove_from_favorites_button(item)
    html = '<button class="btn btn-sm btn-outline-danger ' +
        'dl-remove-from-favorites" data-item-id="' + item.id + '">'
    html += '  <i class="fas fa-heart"></i> Remove'
    html += '</button>'
    raw(html)
  end

end
