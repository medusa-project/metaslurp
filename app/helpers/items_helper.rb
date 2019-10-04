module ItemsHelper

  MAX_MEDIA_TITLE_LENGTH = 120
  MAX_MEDIA_DESCRIPTION_LENGTH = 200

  ##
  # @return [String]
  #
  def filter_field
    html = StringIO.new
    html << '<div class="input-group dl-filter-field">'
    html <<   search_field_tag(:q, params[:q], class: 'form-control',
                               placeholder: 'Filter')
    html << '</div>'
    raw(html.string)
  end

  ##
  # @param item [Object]
  # @param iiif_options [Hash] IIIF Image API parameters.
  # @option iiif_options [String] region
  # @option iiif_options [String] size
  # @param options [Hash] Options to pass to image_tag().
  # @return [String] HTML <img> tag
  #
  def iiif_thumbnail_for(item, iiif_options = {}, options = {})
    iiif_options.symbolize_keys!
    iiif_options[:region] = 'square' unless iiif_options.has_key?(:region)
    iiif_options[:size] = 'max' unless iiif_options.has_key?(:size)

    uri = sprintf('%s/%s/%s/%s/0/default.jpg',
                  Configuration.instance.iiif_endpoint,
                  item.id,
                  iiif_options[:region],
                  iiif_options[:size])
    image_tag(uri, options.merge('data-location': 'remote'))
  end

  ##
  # Renders the given items as a series of
  # [Bootstrap media objects](https://getbootstrap.com/docs/4.0/layout/media-object/).
  #
  # @param items [Enumerable<Item>]
  # @param options [Hash]
  # @option options [Boolean] :link_to_admin
  # @option options [Boolean] :include_type
  # @return [String] HTML string
  #
  def items_as_media(items, options = {})
    html = StringIO.new
    html << '<ul class="list-unstyled">'

    items.each do |item|
      title = raw(StringUtils.truncate(item.title, MAX_MEDIA_TITLE_LENGTH))
      desc = raw(StringUtils.truncate(item.description, MAX_MEDIA_DESCRIPTION_LENGTH))

      # Get the URI to link to.
      ht_url      = item.element(:hathiTrustURL)&.value      # only Book Tracker items will have this
      ia_url      = item.element(:internetArchiveURL)&.value # ditto
      catalog_url = item.element(:uiucCatalogURL)&.value     # ditto
      if ht_url.present?
        item_url = ht_url
      elsif ia_url.present?
        item_url = ia_url
      elsif catalog_url.present?
        item_url = catalog_url
      else
        # If the item is from IDNC/Veridian, append the search query in order
        # to make it appear highlighted on the page.
        item_url = item.source_uri
        if item.content_service.key == 'idnc' and params[:q].present?
          item_url += "&e=-------en-20--1--txt-txIN-#{CGI::escape(params[:q])}-------"
        end
      end

      html << '<li class="media my-4">'
      html <<   '<div class="dl-thumbnail-container">'
      # N.B.: In the DLS, there is a hack to use UI MediaSpace (Kaltura) to
      # serve video thumbnails, but this application doesn't know anything
      # about Kaltura, and also can't serve video thumbnails either, so we use
      # the `reject` method to screen them out.
      if item.images.reject{ |im| im.uri.end_with?('.mpg') }.find(&:master).present?
        html << link_to(item_url) do
          iiif_thumbnail_for(item,
                             { size: '!256,256' },
                             { class: 'mr-3', alt: "Thumbnail for #{item}" })
        end
      else
        html << link_to(item_url) do
          thumbnail_for(item, class: 'mr-3', alt: "Thumbnail for #{item}")
        end
      end

      unless thumbnail_is_local?(item)
        # N.B.: this was made by https://loading.io with the following settings:
        # rolling, color: #cacaca, radius: 25, stroke width: 10, speed: 5, size: 150
        html <<     image_tag('thumbnail-spinner.svg', class: 'dl-load-indicator')
      end
      html <<   '</div>'
      html <<   '<div class="media-body">'
      html <<     '<h5 class="mt-0">'
      html <<       link_to(title, item_url)
      if item.date
        html <<     ' <small>'
        html <<       item.date.year
        html <<     '</small>'
      end
      html <<     '</h5>'
      # Display the currently sorted element value, if not date or title (which
      # are already visible), on its own line:
      # https://bugs.library.illinois.edu/browse/DLDS-45
      sorted_element = ElementDef.all.find{ |e| e.indexed_sort_field == params[:sort] }
      if sorted_element
        exclude_elements = %w(date title)
        el = item.elements
                 .reject{ |e| exclude_elements.include?(e.name) }
                 .find{ |e| e.name == sorted_element.name }
        html <<   "#{sorted_element.label}: #{el.value}<br>" if el
      end

      # Info line (beneath title)
      html <<     '<span class="dl-info-line">'
      info_parts = []
      if options[:include_type]
        info_parts << icon_for(item) + ' ' +
            item.variant.underscore.humanize.split(' ').map(&:capitalize).join(' ')
      end

      if ht_url.present?
        info_parts << link_to(ht_url) do
          raw('<i class="fas fa-external-link-alt"></i> HathiTrust')
        end
      end
      if ia_url.present?
        info_parts << link_to(ia_url) do
          raw('<i class="fas fa-external-link-alt"></i> Internet Archive')
        end
      end
      if catalog_url.present?
        info_parts << link_to("#{catalog_url.chomp('/Description')}/Description") do
          raw('<i class="fas fa-external-link-alt"></i> Library Catalog')
        end
      end
      if ht_url.blank? and ia_url.blank? and catalog_url.blank?
        info_parts << link_to(item_url) do
          raw("<i class=\"fas fa-external-link-alt\"></i> #{item.content_service.name}")
        end
      end

      if options[:link_to_admin]
        info_parts << link_to(admin_item_path(item),
                        class: 'btn btn-sm btn-light',
                        target: '_blank') do
          raw("<i class=\"fas fa-lock\"></i> Admin")
        end
      end
      html <<       info_parts.join(' | ')
      html <<     '</span><br>'
      html <<     desc if desc.present?
      html <<   '</div>'
      html << '</li>'
    end

    html << '</ul>'
    raw(html.string)
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
    html = StringIO.new
    if sortable_elements.any?
      html << '<select name="sort" class="custom-select my-1 mr-sm-2">'
      html <<   '<optgroup label="Sort by&hellip;">'
      html <<     sprintf('<option>%s</option>',
                          params[:q].present? ? 'Relevance' : 'Default Order')

      # If there is an element in the ?sort= query, select it.
      selected_element = sortable_elements.
          select{ |e| e.indexed_sort_field == params[:sort] }.first
      sortable_elements.each do |e|
        selected = (e == selected_element) ? 'selected' : ''
        html << sprintf('<option value="%s" %s>%s</option>',
                        e.indexed_sort_field, selected, e.label)
      end
      html <<   '</optgroup>'
      html << '</select>'
    end
    raw(html.string)
  end

end
