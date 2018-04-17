module ItemsHelper

  MAX_MEDIA_TITLE_LENGTH = 100
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
      desc = truncate(item.description, length: MAX_MEDIA_DESCRIPTION_LENGTH)
      html += '<li class="media my-4">'
      html +=     link_to(item.source_uri) do
        image_tag('test-pattern.jpg', class: 'mr-3',
                  width: MAX_MEDIA_THUMBNAIL_WIDTH,
                  alt: "Thumbnail for #{item}")
      end
      html +=   '<div class="media-body">'
      html +=     '<h5 class="mt-0">'
      html +=       link_to(truncate(item.title, length: MAX_MEDIA_TITLE_LENGTH),
                            item.source_uri)
      html +=     '</h5>'
      html +=     '<span class="dl-info-line">'
      html +=       link_to(item.content_service.name, item.content_service)
      html +=         ' ' + remove_from_favorites_button(item)
      html +=         ' ' + add_to_favorites_button(item)
      if options[:link_to_admin]
        html += link_to(admin_item_path(item), class: 'btn btn-light btn-sm', target: '_blank') do
              raw('<i class="fa fa-lock"></i> Admin View')
            end
      end
      html +=     '</span>'
      html +=     '<br>'
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
    raw(sprintf("Showing %d&ndash;%d of %s %s",
                start + 1,
                last,
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
    sortable_elements = Element.where(sortable: true).order(:index)
    html = ''
    if sortable_elements.any?
      html += '<select name="sort" class="custom-select my-1 mr-sm-2">
          <optgroup label="Sort by&hellip;">
            <option value="">Relevance</option>'

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
    html += '  <i class="fa fa-heart-o"></i>'
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
    html += '  <i class="fa fa-heart"></i> Remove'
    html += '</button>'
    raw(html)
  end

end
