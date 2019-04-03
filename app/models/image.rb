##
# Image attached to an Item.
#
# # Attributes
#
# * crop:     :full or :square
# * size:     :full or a power of two between MIN_POWER_OF_2_SIZE and
#             MAX_POWER_OF_2_SIZE.
# * master:   Whether the image is a master or not. Master images are full-crop
#             and full-size and not necessarily web-ready.
# * uri:      URI of the image. For non-masters, this will ideally have an
#             HTTPS scheme, as HTTP images will have to be proxied through the
#             application. For masters, it may have an S3 scheme if the image
#             server is configured appropriately.
#
class Image

  MIN_POWER_OF_2_SIZE = 6  # 64
  MAX_POWER_OF_2_SIZE = 12 # 4096

  attr_accessor :crop, :master, :size, :uri

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
    struct['master'] = self.master
    struct['crop']   = self.crop.to_s
    struct['size']   = self.size.kind_of?(Symbol) ? 0 : self.size.to_i
    struct['uri']    = self.uri
    struct
  end

  alias :eql? :==

  def hash
    self.uri.hash
  end

end
