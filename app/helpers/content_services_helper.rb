module ContentServicesHelper

  ##
  # @param services [Enumerable<ContentService>]
  # @param options [Hash]
  # @option options [Boolean] :description
  # @return [String] HTML string
  #
  def content_services_as_cards(services, options = {})
    html = '<div class="card-columns">'
    services.each do |service|
      html += '<div class="card">'
      html +=   link_to(service) do
        thumbnail_for(service,
                      class: 'card-img-top',
                      alt: "Thumbnail for #{service}")
      end
      html +=   '<div class="card-body">'
      html +=     '<h5 class="card-title">'
      html +=       link_to(service.name, service)
      html +=       ' <small><span class="badge badge-pill badge-secondary">'
      html +=         number_with_delimiter(service.num_items)
      html +=       '</span></small>'
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
