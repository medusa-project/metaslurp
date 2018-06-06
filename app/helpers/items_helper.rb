module ItemsHelper

  MAX_MEDIA_TITLE_LENGTH = 120
  MAX_MEDIA_DESCRIPTION_LENGTH = 200
  MAX_MEDIA_THUMBNAIL_WIDTH = 120

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
      hl_title = item.highlighted_title || ''
      hl_title_no_tags = strip_tags(hl_title) || ''
      title_tag_length = hl_title.length - hl_title_no_tags.length
      hl_desc = item.highlighted_description || ''
      hl_desc_no_tags = strip_tags(hl_desc) || ''
      desc_tag_length = hl_desc.length - hl_desc_no_tags.length

      desc = truncate(raw(hl_desc),
                      length: MAX_MEDIA_DESCRIPTION_LENGTH + desc_tag_length)
      html += '<li class="media my-4">'
      html +=     link_to(item.source_uri) do
        image_tag('test-pattern.jpg',
                  class: 'mr-3',
                  width: MAX_MEDIA_THUMBNAIL_WIDTH,
                  alt: "Thumbnail for #{item}")
      end
      html +=   '<div class="media-body">'
      html +=     '<h5 class="mt-0">'
      html +=       link_to(truncate(raw(hl_title),
                                     length: MAX_MEDIA_TITLE_LENGTH + title_tag_length),
                            item.source_uri)
      if item.element(:date)
        html +=       " <small>#{item.element(:date)}</small>"
      end
      html +=     '</h5>'
      # Display the currently sorted element value, if not date or title (which
      # are already visible), on its own line:
      # https://bugs.library.illinois.edu/browse/DLDS-45
      sorted_element = ElementDef.all.find{ |e| e.indexed_sort_field == params[:sort] }
      if sorted_element
        # Try to get a highlighted one.
        exclude_elements = %w(date title)
        el = item.highlighted_elements
                 .reject{ |e| exclude_elements.include?(e.name) }
                 .find{ |e| e.name == sorted_element.name }
        unless el # fall back to the non-highlighted one
          el = item.elements
                   .reject{ |e| exclude_elements.include?(e.name) }
                   .find{ |e| e.name == sorted_element.name }
        end
        html +=   "#{sorted_element.label}: #{el.value}<br>" if el
      end
      html +=     '<span class="dl-info-line">'
      html +=       icon_for(item) + ' '
      html +=       item.variant.underscore.humanize.split(' ').map(&:capitalize).join(' ')
      html +=       ' | '
      html +=       link_to(item.content_service.name, item.content_service)
      html +=         ' ' + remove_from_favorites_button(item)
      html +=         ' ' + add_to_favorites_button(item)
      if options[:link_to_admin]
        html += link_to(admin_item_path(item),
                        class: 'btn btn-light btn-sm',
                        target: '_blank') do
              raw('<i class="fas fa-lock"></i> Admin View')
            end
      end
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
    raw(sprintf("Showing %s&ndash;%s of %s %s",
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
