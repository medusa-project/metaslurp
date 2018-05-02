##
# Element definition.
#
class ElementDef < ApplicationRecord

  # N.B.: This should harmonize with SourceElement::INDEX_FIELD_PREFIX.
  INDEX_FIELD_PREFIX = 'local_element_'

  KEYWORD_FIELD_SUFFIX = '.keyword'
  SORT_FIELD_SUFFIX = '.sort'

  attr_accessor :indexed_keyword_field

  has_many :element_mappings, inverse_of: :element_def

  validates :index, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0 },
            allow_blank: false
  validates :label, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true, format: { with: /\A[-a-zA-Z0-9]+\Z/ },
            uniqueness: { case_sensitive: false }

  after_create :adjust_element_indexes_after_create
  after_update :adjust_element_indexes_after_update
  after_destroy :adjust_element_indexes_after_destroy
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

  private

  ##
  # Updates the indexes of all elements to ensure that they are sequential and
  # zero-based.
  #
  def adjust_element_indexes_after_create
    ActiveRecord::Base.transaction do
      ElementDef.all.where('id != ? AND index >= ?', self.id, self.index).each do |e|
        # update_column skips callbacks, which would cause this method to
        # be called recursively.
        e.update_column(:index, e.index + 1)
      end
    end
  end

  ##
  # Updates the indexes of all elements to ensure that they are sequential and
  # zero-based.
  #
  def adjust_element_indexes_after_destroy
    if self.destroyed?
      ActiveRecord::Base.transaction do
        ElementDef.all.order(:index).each_with_index do |element, index|
          # update_column skips callbacks, which would cause this method to be
          # called recursively.
          element.update_column(:index, index) if element.index != index
        end
      end
    end
  end

  ##
  # Updates the indexes of all elements to ensure that they are sequential and
  # zero-based.
  #
  def adjust_element_indexes_after_update
    if self.saved_change_to_index?
      min = [self.index_was, self.index].min
      max = [self.index_was, self.index].max
      increased = (self.index_was < self.index)

      ActiveRecord::Base.transaction do
        ElementDef.all.where('id != ? AND index >= ? AND index <= ?', self.id, min, max).each do |e|
          if increased # shift the range down
            # update_column skips callbacks, which would cause this method to
            # be called recursively.
            e.update_column(:index, e.index - 1)
          else # shift it up
            e.update_column(:index, e.index + 1)
          end
        end
      end
    end
  end

  ##
  # Disallows changes to the name.
  #
  def restrict_name_changes
    self.name_was == self.name
  end

end
