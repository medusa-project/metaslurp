class Element

  KEYWORD_FIELD_SUFFIX = '.keyword'
  SORT_FIELD_SUFFIX = '.sort'

  attr_accessor :name, :value

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
    raise ArgumentError, 'Invalid name' if self.name.blank?
    raise ArgumentError, 'Missing value' if self.value.blank?
  end

end