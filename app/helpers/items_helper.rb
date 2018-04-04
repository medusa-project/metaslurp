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

    items.each do |item|
      desc = truncate(item.description, length: 200)
      html += '<li class="media my-4">'
      html +=     link_to(item.source_uri) do
        image_tag('test-pattern.jpg', class: 'mr-3', width: 120,
                  alt: "Thumbnail for #{item}")
      end
      html +=   '<div class="media-body">'
      html +=     '<h5 class="mt-0">'
      html +=       link_to(item.title, item.source_uri) + ' | '
      html +=       '<small>' + link_to(item.content_service.name, item.content_service) + '</small>'
      if options[:link_to_admin]
        html +=       ' | ' +
                      link_to(admin_item_path(item), class: 'btn btn-light btn-sm', target: '_blank') do
                        raw('<i class="fa fa-lock"></i> Admin View')
                      end
      end
      html +=     '</h5>'
      html +=     desc if desc.present?
      html +=   '</div>'
      html += '</li>'
    end

    html += '</ul>'
    raw(html)
  end

end
