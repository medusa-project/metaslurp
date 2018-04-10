module ContentServicesHelper

  ##
  # @param services [Enumerable<ContentService>]
  # @param options [Hash]
  # @option options [Boolean] :description
  # @return [String] HTML string
  #
  def content_services_as_cards(services, options = {})
    html = '<div class="card-deck">'
    services.each do |service|
      html += '<div class="card">'
      html +=   link_to(service) do
        image_tag('test-pattern.jpg', class: 'card-img-top', alt: "Thumbnail for #{service}")
      end
      html +=   '<div class="card-body">'
      html +=     '<h5 class="card-title">'
      html +=       link_to(service.name, service)
      html +=       " <small><span class=\"badge badge-pill badge-secondary\">#{service.num_items}</span></small>"
      html +=     '</h5>'
      if options[:description]
        html +=   truncate(service.description, length: 200)
      end
      html +=   '</div>'
      html += '</div>'
    end
    html += '</div>'
    raw(html)
  end

end