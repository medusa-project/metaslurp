class Item

  attr_accessor :index_id, :source_uri, :elements

  ##
  # @param obj [Hash] Deserialized JSON.
  # @return [Item]
  # @raises [ArgumentError] If the JSON structure is invalid.
  #
  def self.from_json(jobj)
    jobj = jobj.stringify_keys
    item = Item.new
    item.index_id = jobj['index_id']
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
    struct['source_uri'] = self.source_uri
    struct['elements'] = self.elements.map { |e| e.as_json(options) }
    struct
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
    raise ArgumentError, 'Missing source URI' if self.source_uri.blank?
    raise ArgumentError, 'No elements' if self.elements.empty?
  end

end