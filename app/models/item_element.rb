class ItemElement

  attr_accessor :name, :value

  ##
  # @param obj [Hash] Deserialized JSON.
  # @return [ItemElement]
  # @raises [ArgumentError] If the JSON structure is invalid.
  #
  def self.from_json(jobj)
    jobj = jobj.stringify_keys
    e = ItemElement.new(name: jobj['name'], value: jobj['value'])
    e.validate
    e
  end

  def initialize(args = {})
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def ==(obj)
    obj.object_id == self.object_id || (obj.kind_of?(ItemElement) and
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

  ##
  # @return [void]
  # @raises [ArgumentError] if the instance is invalid.
  #
  def validate
    raise ArgumentError, 'Missing name' if self.name.blank?
    raise ArgumentError, 'Missing value' if self.value.blank?
  end

end