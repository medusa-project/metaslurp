##
# Element definition.
#
class ElementDef < ApplicationRecord

  # N.B.: This should harmonize with SourceElement::INDEX_FIELD_PREFIX and must
  # match a dynamic template in the index schema.
  INDEX_FIELD_PREFIX = 'e_'

  KEYWORD_FIELD_SUFFIX = '.keyword'
  SORT_FIELD_SUFFIX = '.sort'

  attr_accessor :indexed_keyword_field

  has_many :element_mappings, inverse_of: :element_def

  validates :label, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, format: { with: /\A[-a-zA-Z0-9]+\Z/ },
            uniqueness: { case_sensitive: false }

  before_update :restrict_name_changes

  ##
  # @param struct [Hash] Deserialized hash from JSON.parse()
  # @return [ElementDef] New non-persisted instance.
  #
  def self.from_json_struct(struct)
    e = ElementDef.new
    e.update_from_json_struct(struct)
    e
  end

  ##
  # @return [String] Name of the indexed field for the instance.
  #
  def indexed_field
    [INDEX_FIELD_PREFIX, self.name].join
  end

  ##
  # @return [String] Name of the indexed keyword field for the instance.
  #
  def indexed_keyword_field
    if @indexed_keyword_field
      @indexed_keyword_field
    else
      [INDEX_FIELD_PREFIX, self.name, KEYWORD_FIELD_SUFFIX].join
    end
  end

  ##
  # @return [String] Name of the indexed sort field for the instance.
  #
  def indexed_sort_field
    [INDEX_FIELD_PREFIX, self.name, SORT_FIELD_SUFFIX].join
  end

  def to_param
    name
  end

  def to_s
    name
  end

  def update_from_json_struct(struct)
    self.name = struct['name']
    self.label = struct['label']
    self.description = struct['description']
    self.save!
  end

  ##
  # Disallows changes to the name.
  #
  def restrict_name_changes
    self.name_was == self.name
  end

end
