class SourceElement < Element

  # N.B.: This must match a dynamic template in the index schema.
  INDEX_PREFIX = 's_'

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
  # @return [String] Name of the indexed field for the instance.
  #
  def indexed_field
    [INDEX_PREFIX, self.name].join
  end

  ##
  # @return [String] Name of the indexed keyword field for the instance.
  #
  def indexed_keyword_field
    [INDEX_PREFIX, self.name, KEYWORD_FIELD_SUFFIX].join
  end

  ##
  # @return [String] Name of the indexed sort field for the instance.
  #
  def indexed_sort_field
    [INDEX_PREFIX, self.name, SORT_FIELD_SUFFIX].join
  end

end
