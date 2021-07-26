##
# Local element to which a [SourceElement] has been mapped.
#
class LocalElement < Element

  # N.B.: These must match dynamic templates in the index schema.
  DATE_INDEX_PREFIX  = 'local_date_'
  FACET_INDEX_PREFIX = 'local_facet_'
  SORT_INDEX_PREFIX  = 'local_sort_'
  TEXT_INDEX_PREFIX  = 'local_text_'

  ##
  # @return [String] Name of the indexed field for the instance.
  #
  def indexed_facet_field
    [FACET_INDEX_PREFIX, self.name].join
  end

  ##
  # @return [String] Name of the indexed sort field for the instance.
  #
  def indexed_sort_field
    [SORT_INDEX_PREFIX, self.name].join
  end

  ##
  # @return [String] Name of the indexed text field for the instance.
  #
  def indexed_text_field
    [TEXT_INDEX_PREFIX, self.name].join
  end

end
