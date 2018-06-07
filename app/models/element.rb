class Element

  # N.B.: This should harmonize with ElementDef::INDEX_FIELD_PREFIX and must
  # match a dynamic template in the index schema.
  INDEX_FIELD_PREFIX = 's_'

  attr_accessor :name, :value

  ##
  # @param obj [Hash] Deserialized JSON.
  # @return [Element]
  # @raises [ArgumentError] If the JSON structure is invalid.
  #
  def self.from_json(jobj)
    jobj = jobj.stringify_keys
    e = Element.new(name: jobj['name'], value: jobj['value'])
    e.validate
    e
  end

  def initialize(args = {})
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def ==(obj)
    obj.object_id == self.object_id || (obj.kind_of?(Element) and
        obj.name == self.name and obj.value == self.value)
  end

  ##
  # @return [Hash]
  #
  def as_json(options = {})
    struct = super(options)
    struct['name'] = self.name
    struct['value'] = self.value
    struct
  end

  def hash
    [self.name, self.value].hash
  end

  ##
  # @return [String] Name of the indexed field for the instance.
  #
  def indexed_field
    [INDEX_FIELD_PREFIX, self.name].join
  end

  ##
  # @return [String] The value.
  #
  def to_s
    "#{self.value}"
  end

  ##
  # @return [void]
  # @raises [ArgumentError] if the instance is invalid.
  #
  def validate
    raise ArgumentError, 'Missing name' if self.name.blank?
    raise ArgumentError, 'Invalid name' unless self.name.match?(/^[A-Za-z\d]*$/)
    raise ArgumentError, 'Missing value' if self.value.blank?
  end

end