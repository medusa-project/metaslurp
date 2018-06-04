class LocalElement < Element

  # N.B.: These must match dynamic templates in the index schema.
  DATE_INDEX_PREFIX    = 'd_'
  KEYWORD_INDEX_PREFIX = 'k_'
  STRING_INDEX_PREFIX  = 'e_'
  TEXT_INDEX_PREFIX    = 't_'

  ##
  # @return [String] Name of the indexed field for the instance.
  #
  def indexed_field
    [STRING_INDEX_PREFIX, self.name].join
  end

  ##
  # @return [String] Name of the indexed keyword field for the instance.
  #
  def indexed_keyword_field
    [STRING_INDEX_PREFIX, self.name, KEYWORD_FIELD_SUFFIX].join
  end

  ##
  # @return [String] Name of the indexed sort field for the instance.
  #
  def indexed_sort_field
    [STRING_INDEX_PREFIX, self.name, SORT_FIELD_SUFFIX].join
  end

end
