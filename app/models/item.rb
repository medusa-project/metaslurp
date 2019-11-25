##
# Encapsulates a unit of intellectual content.
#
# # Structure
#
# All items are associated with a {ContentService}. The association is via a
# `service_key` attribute corresponding to a content service key. There are
# also `container_id` and `parent_id` attributes that can be used to support
# placement inside some kind of "container" (such as a {Variants::COLLECTION
# collection-variant Item}) and arbitrary item trees.
#
# # Identifiers
#
# Identifiers are unique across all items and content services and stable from
# harvest to harvest. Those are the only requirements, but it's also nice if
# they aren't too ugly in URIs.
#
# # Description
#
# Items have a number of hard-coded attributes (see below) as well as
# collections of {SourceElement}s, which represent metadata elements of the
# instance within the content service, and {LocalElement}s, which represent
# local metadata elements to which {SourceElement}s get mapped. Hard-coded
# attributes are used by the system. {LocalElement}s contain free-form strings
# and can be mapped to {ElementDef}s to control how they work in terms of
# searching, faceting, etc. on a per-{ContentService} basis.
#
# # Dates
#
# Free-form date strings are allowed in any element, but they are indexed as
# non-normalized strings, so aren't very useful. Instead, they can be indexed
# as normalized dates by setting the `data_type` of the corresponding
# {ElementDef} to {ElementDef::DataType::DATE}. When the element is indexed,
# its date/time string will be normalized into a {Time} object which will be
# indexed in a date field.
#
# # Indexing
#
# Items are searchable via Elasticsearch. High-level search functionality is
# available via the {ItemFinder} class.
#
# All instance attributes are indexed, as well as both source and local mapped
# elements. This makes instances "round-trippable," so they can be transformed
# to ES documents via {as_indexed_json}, sent to ES, retrieved, and
# deserialized back into instances via {from_indexed_json}.
#
# The index schema should use dynamic templates for as many fields as possible.
# It may take a long time to repopulate an index, so having to create a new
# index just to support a new field would be a major inconvenience.
#
# # Attributes
#
# * `container_id`   Identifier of a container (not parent) item--which would
#                    typically be one with a {Variants::COLLECTION} variant.
# * `container_name` Name of a container (not parent). Used as a fallback to
#                    `container_id` when the container is not an {Item}.
# * `elements`       Enumerable of {SourceElement}s.
# * `full_text`      Full text.
# * `harvest_key`    Key of the {Harvest} during which the item was last
#                    updated.
# * `id`             Identifier within the application.
# * `images`         Set of associated {Image}s. One of them may be a master
#                    image.
# * `local_elements` {Enumerable} of {LocalElement}s.
# * `parent_id`      Identifier of a parent (not container) item.
# * `score`          Relevance score assigned by Elasticsearch.
# * `service_key`    Key of the {ContentService} in which the instance resides.
# * `source_id`      Unique identifier of the instance.
# * `variant`        Like a subclass. Used to differentiate types of instances
#                    that all have more-or-less the same properties.
#
# ## Adding an attribute
#
# 1. Document it above
# 2. Add an `attr_accessor` for it
# 3. Add it to {validate}, if necessary
# 4. Add it to {from_json} & {as_json}, if necessary
# 5. Add it to {IndexFields}, if necessary
# 6. Add it to {from_indexed_json} & {as_indexed_json}, if necessary
# 7. Update tests for all of the above
# 8. Update the {ItemsController} API test
# 9. Add it to the API documentation
# 10. Update the harvester and re-harvest everything
#
class Item

  LOGGER = CustomLogger.new(Item)

  ELASTICSEARCH_INDEX = 'entities'

  attr_accessor :container_id, :container_name, :full_text, :harvest_key, :id,
                :last_indexed, :media_type, :parent_id, :score, :service_key,
                :source_id, :source_uri, :variant
  attr_reader :elements, :images, :local_elements

  ##
  # System (non-metadata) fields. These should all be dynamic fields if at all
  # possible.
  #
  class IndexFields
    CONTAINER_ID   = 'system_keyword_container_id'
    CONTAINER_NAME = 'system_keyword_container_name'
    FULL_TEXT      = 'system_text_full_text'
    HARVEST_KEY    = 'system_keyword_harvest_key'
    ID             = '_id'
    IMAGES         = 'system_object_images'
    LAST_INDEXED   = 'system_date_last_indexed'
    PARENT_ID      = 'system_keyword_parent_id'
    MEDIA_TYPE     = 'system_keyword_media_type'
    SERVICE_KEY    = 'system_keyword_service_key'
    SOURCE_ID      = 'system_keyword_source_id'
    SOURCE_URI     = 'system_keyword_source_uri'
    VARIANT        = 'system_keyword_variant'
  end

  ##
  # To add a variant:
  #
  # 1. Add it here
  # 2. Make {ApplicationHelper#icon_for} and {ApplicationHelper#thumbnail_for}
  #    aware of it
  #
  class Variants
    BOOK           = 'Book'
    COLLECTION     = 'Collection'
    DATA_SET       = 'DataSet'
    ENTITY         = 'Entity'
    FILE           = 'File'
    ITEM           = 'Item'
    NEWSPAPER_PAGE = 'NewspaperPage'
    PAPER          = 'Paper'

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
    config = Configuration.instance
    ElasticsearchClient.instance.get_document(config.elasticsearch_index, id)
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
    item.score = jobj['_score'] || 0

    jsrc                = jobj['_source']
    item.container_id   = jsrc[IndexFields::CONTAINER_ID]
    item.container_name = jsrc[IndexFields::CONTAINER_NAME]
    item.full_text      = jsrc[IndexFields::FULL_TEXT]
    item.harvest_key    = jsrc[IndexFields::HARVEST_KEY]
    item.last_indexed   = Time.iso8601(jsrc[IndexFields::LAST_INDEXED]) rescue nil
    item.media_type     = jsrc[IndexFields::MEDIA_TYPE]
    item.parent_id      = jsrc[IndexFields::PARENT_ID]
    item.service_key    = jsrc[IndexFields::SERVICE_KEY]
    item.source_id      = jsrc[IndexFields::SOURCE_ID]
    item.source_uri     = jsrc[IndexFields::SOURCE_URI]
    item.variant        = jsrc[IndexFields::VARIANT]

    # Read access images.
    jsrc[IndexFields::IMAGES]&.each do |struct|
      item.images << Image.new(size: struct['size'].to_i,
                               crop: struct['crop'].to_sym,
                               uri: struct['uri'],
                               master: struct['master'])
    end

    # Read source elements.
    prefix = SourceElement::RAW_INDEX_PREFIX
    jsrc.keys.select{ |k| k.start_with?(prefix) }.each do |key|
      name = key[prefix.length..key.length]
      jsrc[key].each do |value|
        item.elements << SourceElement.new(name: name, value: value)
      end
    end

    # Read local text elements.
    prefix = LocalElement::TEXT_INDEX_PREFIX
    jsrc.keys.select{ |k| k.start_with?(prefix) }.each do |key|
      name = key[prefix.length..key.length]
      jsrc[key].each do |value|
        item.local_elements << LocalElement.new(name: name, value: value)
      end
    end

    # Read local date elements.
    prefix = LocalElement::DATE_INDEX_PREFIX
    jsrc.keys.select{ |k| k.start_with?(prefix) }.each do |key|
      name = key[prefix.length..key.length]
      item.local_elements << LocalElement.new(name: name, value: jsrc[key])
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
    item.container_id   = jobj['container_id']
    item.container_name = jobj['container_name']
    item.full_text      = jobj['full_text']
    item.harvest_key    = jobj['harvest_key']
    item.id             = jobj['id']
    item.media_type     = jobj['media_type']
    item.parent_id      = jobj['parent_id']
    item.service_key    = jobj['service_key']
    item.source_id      = jobj['source_id']
    item.source_uri     = jobj['source_uri']
    item.variant        = jobj['variant']

    # Read access images.
    if jobj['images'].respond_to?(:each)
      jobj['images'].each do |struct|
        item.images << Image.new(size: struct['size'].to_i,
                                 crop: struct['crop'].to_sym,
                                 uri: struct['uri'],
                                 master: struct['master'])
      end
    end

    # Read elements.
    if jobj['elements'].respond_to?(:each)
      jobj['elements'].each do |je|
        item.elements << SourceElement.from_json(je)
      end
    end

    item.validate
    item
  end

  def initialize(args = {})
    @elements       = Set.new
    @images         = Set.new
    @local_elements = Set.new

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
  # {fetch_indexed_json}.
  #
  # N.B.: Changing this may require re-harvesting and maybe even updating the
  # index schema.
  #
  # @return [Hash] Indexable JSON representation of the instance.
  #
  def as_indexed_json
    doc = {}
    doc[IndexFields::CONTAINER_ID]   = self.container_id
    doc[IndexFields::CONTAINER_NAME] = self.container_name
    doc[IndexFields::FULL_TEXT]      = self.full_text
    doc[IndexFields::HARVEST_KEY]    = self.harvest_key
    doc[IndexFields::IMAGES]         = self.images.map(&:as_json)
    doc[IndexFields::LAST_INDEXED]   = Time.now.utc.iso8601
    doc[IndexFields::MEDIA_TYPE]     = self.media_type
    doc[IndexFields::PARENT_ID]      = self.parent_id
    doc[IndexFields::SERVICE_KEY]    = self.service_key
    doc[IndexFields::SOURCE_ID]      = self.source_id
    doc[IndexFields::SOURCE_URI]     = self.source_uri
    doc[IndexFields::VARIANT]        = self.variant

    # Elements
    self.elements.each do |src_elem|
      value = src_elem.value

      # Raw source field
      unless doc.keys.include?(src_elem.raw_field)
        doc[src_elem.raw_field] = []
      end
      doc[src_elem.raw_field] << value

      # Analyzed source field
      unless doc.keys.include?(src_elem.analyzed_field)
        doc[src_elem.analyzed_field] = []
      end
      doc[src_elem.analyzed_field] << value

      # Add the mapped local element, if one exists.
      e_def = self.content_service&.element_def_for_element(src_elem)
      if e_def
        unless doc.keys.include?(e_def.indexed_facet_field)
          doc[e_def.indexed_facet_field] = []
        end
        unless doc.keys.include?(e_def.indexed_sort_field)
          doc[e_def.indexed_sort_field] = []
        end
        unless doc.keys.include?(e_def.indexed_text_field)
          doc[e_def.indexed_text_field] = []
        end
        case e_def.data_type
        when ElementDef::DataType::DATE
          begin
            date = Marc::Dates::parse(value).first&.utc
            # Marc::Dates treats five-digit years as valid, but Elasticsearch
            # doesn't accept them in date fields. Here we discard
            # distant-future years.
            if date.year < 2050
              doc[e_def.indexed_date_field] = date.iso8601
            else
              raise ArgumentError, "Invalid date: #{date}"
            end
          rescue ArgumentError => e
            LOGGER.warn('as_indexed_json(): %s', e)
          end
        else
          # If the ElementDef has a matching ValueMapping, convert the source
          # value to the local value.
          mapping = e_def.value_mappings.where(source_value: value).first
          if mapping
            value = mapping.local_value
          end
          max_length = ElasticsearchClient::MAX_KEYWORD_FIELD_LENGTH
          doc[e_def.indexed_sort_field]  << StringUtils.strip_leading_articles(value)[0..max_length]
          # We want to strip tags but not escape entities, which there is
          # apparently no easy way to do using Rails' built-in sanititzer. For
          # now, allowing ampersands through should be enough.
          doc[e_def.indexed_text_field]  << ActionView::Base.full_sanitizer.sanitize(value).gsub('&amp;', '&')
          doc[e_def.indexed_facet_field] << doc[e_def.indexed_text_field][0..max_length]
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
    struct['container_id']   = self.container_id
    struct['container_name'] = self.container_name
    struct['images']         = self.images.as_json
    struct['variant']        = self.variant
    struct['elements']       = self.elements.map { |e| e.as_json(options) }
    struct['full_text']      = self.full_text
    struct['harvest_key']    = self.harvest_key
    struct['id']             = self.id
    struct['media_type']     = self.media_type
    struct['parent_id']      = self.parent_id
    struct['service_key']    = self.service_key
    struct['source_id']      = self.source_id
    struct['source_uri']     = self.source_uri
    struct
  end

  ##
  # @return [Item] The containing Item, which may be nil, in which case
  #                {container_name} should be used instead.
  #
  def container
    self.container_id.present? ? Item.find(self.container_id) : nil
  end

  ##
  # @return [ContentService] Content service corresponding to `service_key`.
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

  alias :eql? :==

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
  # (Re)indexes the instance into the latest index.
  #
  # @return [void]
  # @raises [IOError]
  #
  def save
    config = Configuration.instance
    ElasticsearchClient.instance.index_document(config.elasticsearch_index,
                                                self.id,
                                                self.as_indexed_json)
  end

  alias :save! :save

  ##
  # @return [Image]
  #
  def thumbnail_image
    # Use the largest available access image up to MAX_THUMBNAIL_SIZE.
    # Prefer a square crop, but return a full crop if it's a better fit.
    self.images
        .reject{ |im| im.uri.end_with?('.mpg') } # ugly hack; see similar technique in ItemsHelper.items_as_media()
        .select{ |im| im.size <= ApplicationHelper::MAX_THUMBNAIL_SIZE }
        .sort{ |a, b| [a.size, a.crop] <=> [b.size, b.crop] }
        .last
  end

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