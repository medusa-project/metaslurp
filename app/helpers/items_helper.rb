module ItemsHelper

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

    title_length = 100
    description_length = 200
    thumbnail_width = 120

    items.each do |item|
      desc = truncate(item.description, length: description_length)
      html += '<li class="media my-4">'
      html +=     link_to(item.source_uri) do
        image_tag('test-pattern.jpg', class: 'mr-3', width: thumbnail_width,
                  alt: "Thumbnail for #{item}")
      end
      html +=   '<div class="media-body">'
      html +=     '<h5 class="mt-0">'
      html +=       link_to(truncate(item.title, length: title_length), item.source_uri)
      html +=       ' ' + remove_from_favorites_button(item)
      html +=       ' ' + add_to_favorites_button(item)
      html +=     '</h5>'

      html +=     link_to(item.content_service.name, item.content_service)
      if options[:link_to_admin]
        html += link_to(admin_item_path(item), class: 'btn btn-light btn-sm', target: '_blank') do
              raw('<i class="fa fa-lock"></i> Admin View')
            end
      end
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
  def search_status(total_num_results, start, num_results_shown)
    last = [total_num_results, start + num_results_shown].min
    raw(sprintf("Showing %d&ndash;%d of %s items",
                start + 1, last,
                number_with_delimiter(total_num_results)))
  end

  private

  ##
  # @param item [Item]
  # @return [String] HTML <button> element
  #
  def add_to_favorites_button(item)
    html = '<button class="btn btn-default btn-sm ' +
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
    html = '<button class="btn btn-sm btn-danger ' +
        'dl-remove-from-favorites" data-item-id="' + item.id + '">'
    html += '  <i class="fa fa-heart"></i> Remove'
    html += '</button>'
    raw(html)
  end

end