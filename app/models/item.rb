##
# # Adding Attributes
#
# 1. Add an attribute to the `attr_accessor`
# 2. Add it to validate()
# 3. Add it to from_json()
# 4. Add it to as_json()
# 5. Update tests for all of the above
#
class Item

  attr_accessor :index_id, :service_key, :source_uri, :elements

  ##
  # @param obj [Hash] Deserialized JSON.
  # @return [Item]
  # @raises [ArgumentError] If the JSON structure is invalid.
  #
  def self.from_json(jobj)
    jobj = jobj.stringify_keys
    item = Item.new
    item.index_id = jobj['index_id']
    item.service_key = jobj['service_key']
    item.source_uri = jobj['source_uri']
    jobj['elements'].each do |jelement|
      item.elements << ItemElement.from_json(jelement)
    end
    item.validate
    item
  end

  def initialize(args = {})
    @elements = Set.new
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def ==(obj)
    obj.object_id == self.object_id ||
        (obj.kind_of?(Item) and obj.index_id == self.index_id)
  end

  ##
  # @return [Hash]
  #
  def as_json(options = {})
    struct = super(options)
    struct['index_id'] = self.index_id
    struct['service_key'] = self.service_key
    struct['source_uri'] = self.source_uri
    struct['elements'] = self.elements.map { |e| e.as_json(options) }
    struct
  end

  ##
  # @return [ContentService] Service corresponding to `service_key`.
  #
  def content_service
    ContentService.find_by_key(self.service_key)
  end

  def to_s
    "#{self.index_id}"
  end

  ##
  # @return [void]
  # @raises [ArgumentError] if the instance is invalid.
  #
  def validate
    raise ArgumentError, 'Missing ID' if self.index_id.blank?
    raise ArgumentError, 'Invalid service key' unless
        ContentService.pluck(:key).include?(self.service_key)
    raise ArgumentError, 'Missing source URI' if self.source_uri.blank?
    raise ArgumentError, 'No elements' if self.elements.empty?
  end

end