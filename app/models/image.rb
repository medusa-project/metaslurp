class Image

  attr_accessor :crop, :size, :uri

  def initialize(args = {})
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def ==(obj)
    obj.object_id == self.object_id || (obj.kind_of?(Image) and
        obj.uri == self.uri)
  end

  def as_json(options = {})
    struct = super(options)
    struct['crop'] = self.crop.to_s
    struct['size'] = self.size.to_i
    struct['uri'] = self.uri
    struct
  end

  alias :eql? :==

  def hash
    self.uri.hash
  end

end
