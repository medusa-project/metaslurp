##
# Encapsulates a unit of intellectual content.
#
# # Structure
#
# Every item "resides" in a content service (ContentService). The association
# is via a key attribute corresponding to a content service key. Items are
# "flat" and have no relationships to each other.
#
# # Identifiers
#
# Identifiers are unique across all items and content services and stable from
# harvest to harvest. Those are the only requirements, but it's nice if they
# also look pretty in URIs.
#
# # Description
#
# Items have a number of hard-coded attributes (see below) as well as
# collections of Elements, which represent metadata elements of the instance
# within the content service, and Elements, which represent local metadata
# elements to which Elements get mapped. Hard-coded attributes are used by the
# system. Elements contain free-form strings and can be mapped to Elements to
# control how they work with regard to searching, faceting, etc. on a
# per-ContentService basis.
#
# # Dates
#
# Free-form date strings are allowed in any element, but they are indexed as
# non-normalized strings, so aren't very useful. Instead, they can be indexed
# as normalized dates by setting the data_type of the corresponding ElementDef
# to ElementDef::DataType::DATE. When the element is indexed,
# TimeUtils::string_date_to_time() will be used to obtain a normalized Time
# object representing it, and that will be indexed in a date field.
#
# # Indexing
#
# Items are searchable via Elasticsearch. High-level search functionality is
# available via the ItemFinder class.
#
# All instance attributes are indexed, as well as both source and local mapped
# elements. This makes instances "round-trippable," so they can be transformed
# to ES documents via `as_indexed_json()`, sent to ES, retrieved, and
# deserialized back into instances via `from_indexed_json()`.
#
# The index schema should use dynamic templates for as many fields as possible.
# An index may require weeks to repopulate, so having to create a new index
# just to support a new field is a major inconvenience.
#
# # Attributes
#
# * access_image_uri      URI of a high-quality access image.
# * elements:             Enumerable of SourceElements.
# * full_text:            Full text.
# * harvest_key:          Key of the harvest during which the item was last
#                         updated.
# * highlighted_elements: Enumerable of Elements that match a query, whose
#                         values contain HTML tags representing the matches.
# * id:                   Identifier within the application.
# * local_elements:       Enumerable of LocalElements.
# * service_key:          Key of the ContentService from which the instance was
#                         obtained.
# * source_id:            Identifier of the instance within its ContentService.
# * variant:              Like a subclass. Used to differentiate types of
#                         instances that all have more-or-less the same
#                         properties.
#
# ## Adding an attribute
#
# 1. Document it above
# 2. Add an `attr_accessor` for it
# 3. Add it to validate(), if necessary
# 4. Add it to from_json() & as_json(), if necessary
# 5. Add it to IndexFields, if necessary
# 6. Add it to from_indexed_json() & as_indexed_json(), if necessary
# 7. Update tests for all of the above
# 8. Update the ItemsController API test
# 9. Add it to the API documentation
# 10. Update the harvester and reindex everything
#
class Item

  ELASTICSEARCH_INDEX = 'entities'
  ELASTICSEARCH_TYPE = 'entity'

  attr_accessor :access_image_uri, :full_text, :harvest_key, :id, :last_indexed,
                :media_type, :service_key, :source_id, :source_uri, :variant
  attr_reader :elements, :highlighted_elements, :local_elements

  ##
  # These should all be dynamic fields if at all possible (see class doc).
  #
  class IndexFields
    ACCESS_IMAGE_URI = 'k_access_image_uri'
    FULL_TEXT = 't_full_text'
    HARVEST_KEY = 'k_harvest_key'
    ID = '_id'
    LAST_INDEXED = 'd_last_indexed'
    MEDIA_TYPE = 'k_media_type'
    SERVICE_KEY = 'k_service_key'
    SOURCE_ID = 'k_source_id'
    SOURCE_URI = 'k_source_uri'
    VARIANT = 'k_variant'
  end

  ##
  # To add a variant:
  #
  # 1. Add it here
  # 2. Make ApplicationHelper.icon_for() aware of it
  #
  class Variants
    BOOK           = 'Book'
    COLLECTION     = 'Collection'
    DATA_SET       = 'DataSet'
    FILE           = 'File'
    ITEM           = 'Item'
    NEWSPAPER_PAGE = 'NewspaperPage'

    ##
    # @return [Enumerable<String>] String values of all variants.
    #
    def self.all
      self.constants.map{ |c| self.const_get(c) }
    end
  end

  ##
  # @param id [String]  Item ID.
  # @return [Hash, nil] The current indexed document for the item with the
  #                     given ID.
  # @raises [IOError]
  #
  def self.fetch_indexed_json(id)
    index = ElasticsearchIndex.latest(ELASTICSEARCH_INDEX)
    ElasticsearchClient.instance.get_document(index.name,
                                              ELASTICSEARCH_TYPE, id)
  end

  ##
  # @param id [String] Item ID.
  # @return [Item]
  # @raises [ActiveRecord::RecordNotFound]
  # @raises [IOError]
  #
  def self.find(id)
    doc = fetch_indexed_json(id)
    if doc
      Item.from_indexed_json(doc)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  ##
  # @param jobj [Hash] Deserialized JSON from an indexed document.
  # @return [Item]
  #
  def self.from_indexed_json(jobj)
    item = Item.new
    item.id = jobj[IndexFields::ID]

    jsrc = jobj['_source']
    item.access_image_uri = jsrc[IndexFields::ACCESS_IMAGE_URI]
    item.full_text = jsrc[IndexFields::FULL_TEXT]
    item.harvest_key = jsrc[IndexFields::HARVEST_KEY]
    item.last_indexed = Time.iso8601(jsrc[IndexFields::LAST_INDEXED]) rescue nil
    item.media_type = jsrc[IndexFields::MEDIA_TYPE]
    item.service_key = jsrc[IndexFields::SERVICE_KEY]
    item.source_id = jsrc[IndexFields::SOURCE_ID]
    item.source_uri = jsrc[IndexFields::SOURCE_URI]
    item.variant = jsrc[IndexFields::VARIANT]

    # Read source elements.
    prefix = SourceElement::INDEX_PREFIX
    jsrc.keys.select{ |k| k.start_with?(prefix) }.each do |key|
      name = key[prefix.length..key.length]
      # This should always be true, but just in case there is a string value
      # instead of an array for some reason...
      if jsrc[key].respond_to?(:each)
        jsrc[key].each do |value|
          item.elements << SourceElement.new(name: name, value: value)
        end
      else
        item.elements << SourceElement.new(name: name, value: jsrc[key])
      end
    end

    # Read local string elements.
    prefix = LocalElement::STRING_INDEX_PREFIX
    jsrc.keys.select{ |k| k.start_with?(prefix) }.each do |key|
      name = key[prefix.length..key.length]
      if jsrc[key].respond_to?(:each)
        jsrc[key].each do |value|
          item.local_elements << LocalElement.new(name: name, value: value)
        end
      else
        item.local_elements << LocalElement.new(name: name, value: jsrc[key])
      end
    end

    # Read local date elements.
    prefix = LocalElement::DATE_INDEX_PREFIX
    jsrc.keys.select{ |k| k.start_with?(prefix) }.each do |key|
      name = key[prefix.length..key.length]
      item.local_elements << LocalElement.new(name: name, value: jsrc[key])
    end

    # Read highlighted elements.
    jhl = jobj['highlight']

    if jhl # will be nil if highlighting is disabled
      prefix = LocalElement::STRING_INDEX_PREFIX
      jhl.keys.select{ |k| k.start_with?(prefix) }.each do |key|
        name = key[prefix.length..key.length]
        jhl[key].each do |value|
          item.highlighted_elements << LocalElement.new(name: name, value: value)
        end
      end
    end

    item
  end

  ##
  # @param jobj [Hash] Deserialized JSON.
  # @return [Item]
  # @raises [ArgumentError] If the JSON structure is invalid.
  #
  def self.from_json(jobj)
    jobj = jobj.stringify_keys
    item = Item.new
    item.access_image_uri = jobj['access_image_uri']
    if jobj['elements'].respond_to?(:each)
      jobj['elements'].each { |je| item.elements << SourceElement.from_json(je) }
    end
    item.full_text = jobj['full_text']
    item.harvest_key = jobj['harvest_key']
    item.id = jobj['id']
    item.media_type = jobj['media_type']
    item.service_key = jobj['service_key']
    item.source_id = jobj['source_id']
    item.source_uri = jobj['source_uri']
    item.variant = jobj['variant']

    item.validate
    item
  end

  def initialize(args = {})
    @elements             = Set.new
    @highlighted_elements = Set.new
    @local_elements       = Set.new
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def ==(obj)
    obj.object_id == self.object_id ||(obj.is_a?(Item) and obj.id == self.id)
  end

  ##
  # Returns an indexable JSON representation of the instance. Note that this
  # will not be the same as what is currently indexed; for that, see
  # fetch_indexed_json().
  #
  # N.B.: Changing this may require reindexing and maybe even updating the
  # index schema.
  #
  # @return [Hash] Indexable JSON representation of the instance.
  #
  def as_indexed_json
    doc = {}
    doc[IndexFields::ACCESS_IMAGE_URI] = self.access_image_uri
    doc[IndexFields::FULL_TEXT] = self.full_text
    doc[IndexFields::HARVEST_KEY] = self.harvest_key
    doc[IndexFields::LAST_INDEXED] = Time.now.utc.iso8601
    doc[IndexFields::MEDIA_TYPE] = self.media_type
    doc[IndexFields::SERVICE_KEY] = self.service_key
    doc[IndexFields::SOURCE_ID] = self.source_id
    doc[IndexFields::SOURCE_URI] = self.source_uri
    doc[IndexFields::VARIANT] = self.variant

    self.elements.each do |src_elem|
      value = src_elem.value[0..ElasticsearchClient::MAX_KEYWORD_FIELD_LENGTH]

      # Add the source element value to an array, as there may be more than
      # one element with the same name.
      unless doc.keys.include?(src_elem.indexed_field)
        doc[src_elem.indexed_field] = []
      end
      doc[src_elem.indexed_field] << value

      # Add the mapped local element, if one exists.
      e_def = self.content_service&.element_def_for_element(src_elem)
      if e_def
        unless doc.keys.include?(e_def.indexed_field)
          doc[e_def.indexed_field] = []
        end
        case e_def.data_type
          when ElementDef::DataType::DATE
            begin
              doc[e_def.indexed_field] =
                  TimeUtils::string_date_to_time(value)&.iso8601
            rescue ArgumentError => e
              Rails.logger.warn("Item.as_indexed_json(): #{e}")
            end
          else
            doc[e_def.indexed_field] << value
        end
      end
    end
    doc
  end

  ##
  # @return [Hash]
  #
  def as_json(options = {})
    struct = super(options)
    struct['access_image_uri'] = self.access_image_uri
    struct['variant'] = self.variant
    struct['elements'] = self.elements.map { |e| e.as_json(options) }
    struct['full_text'] = self.full_text
    struct['harvest_key'] = self.harvest_key
    struct['id'] = self.id
    struct['media_type'] = self.media_type
    struct['service_key'] = self.service_key
    struct['source_id'] = self.source_id
    struct['source_uri'] = self.source_uri
    struct
  end

  ##
  # @return [ContentService] Service corresponding to `service_key`.
  #
  def content_service
    ContentService.find_by_key(self.service_key)
  end

  ##
  # @return [Time, nil]
  #
  def date
    value = self.element('date')&.value
    if value
      return Time.parse(value) rescue nil
    end
    nil
  end

  ##
  # @return [String]
  #
  def description
    self.element('description')&.value
  end

  ##
  # @param name [String]
  # @return [Element] Local element with the given name.
  #
  def element(name)
    self.local_elements.find{ |e| e.name == name.to_s }
  end

  def eql?(obj)
    self.==(obj)
  end

  ##
  # @return [Harvest] Harvest corresponding to `harvest_key`.
  #
  def harvest
    Harvest.find_by_key(self.harvest_key)
  end

  def hash
    self.id.hash
  end

  ##
  # @return [String] Highlighted title value, or the result of `title`.
  #
  def highlighted_description
    self.highlighted_elements.find{ |e| e.name == 'description' }&.value ||
        self.description
  end

  ##
  # @return [String] Highlighted title value, or the result of `title`.
  #
  def highlighted_title
    self.highlighted_elements.find{ |e| e.name == 'title' }&.value || self.title
  end

  ##
  # (Re)indexes the instance into the latest index.
  #
  # @return [void]
  # @raises [IOError]
  #
  def save
    index = ElasticsearchIndex.latest(ELASTICSEARCH_INDEX)
    ElasticsearchClient.instance.index_document(index.name,
                                                ELASTICSEARCH_TYPE,
                                                self.id,
                                                self.as_indexed_json)
  end

  alias_method :save!, :save

  ##
  # @return [String]
  #
  def title
    self.element('title')&.value || 'Untitled'
  end

  def to_s
    "#{self.id}"
  end

  ##
  # @return [void]
  # @raises [ArgumentError] if the instance is invalid.
  #
  def validate
    raise ArgumentError, 'Missing ID' if self.id.blank?
    raise ArgumentError, 'ID may not contain slashes' if self.id.include?('/')
    raise ArgumentError, 'Invalid harvest key' unless
        Harvest.find_by_key(self.harvest_key)
    raise ArgumentError, 'Invalid service key' unless
        ContentService.find_by_key(self.service_key)
    raise ArgumentError, 'Invalid media type' if
        self.media_type.present? and (self.media_type =~ /[a-z]\/[a-z0-9]/).nil?
    raise ArgumentError, 'Missing source ID' if self.source_id.blank?
    raise ArgumentError, 'Missing source URI' if self.source_uri.blank?
    raise ArgumentError, 'Invalid variant' unless
        Variants.all.include?(self.variant)
  end

end