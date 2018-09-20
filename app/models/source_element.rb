class SourceElement < Element

  # N.B.: These must match dynamic templates in the index schema.
  RAW_INDEX_PREFIX = 'source_raw_'
  ANALYZED_INDEX_PREFIX = 'source_search_'

  ##
  # @param obj [Hash] Deserialized JSON.
  # @return [Element]
  # @raises [ArgumentError] If the JSON structure is invalid.
  #
  def self.from_json(jobj)
    jobj = jobj.stringify_keys
    e = SourceElement.new(name: jobj['name'], value: jobj['value'])
    e.validate
    e
  end

  ##
  # @return [String] Name of the analyzed field for the instance.
  #
  def analyzed_field
    [ANALYZED_INDEX_PREFIX, self.name].join
  end

  ##
  # @return [String] Name of the raw field for the instance.
  #
  def raw_field
    [RAW_INDEX_PREFIX, self.name].join
  end

end
