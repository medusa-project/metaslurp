json.start @start
json.limit @limit
json.numResults @count

json.results do
  json.array! @items do |item|
    service = ContentService.find_by_key(item.service_key)
    json.id item.id
    json.variant item.variant
    json.full_text item.full_text
    json.media_type item.media_type
    json.images item.images
    json.source_uri item.source_uri
    json.last_indexed item.last_indexed
    json.elements do
      json.array! item.local_elements do |element|
        e_def = service.element_def_for_element(element)
        json.name element.name
        json.label e_def ? e_def.label : element.name
        json.value element.value
      end
    end
  end
end

json.facets do
  json.array! @facets do |facet|
    json.name facet.name
    json.set! :field, facet.field
    json.buckets do
      json.array! facet.buckets do |bucket|
        json.name bucket.name
        json.label bucket.label
        json.set! :count, bucket.count
      end
    end
  end
end