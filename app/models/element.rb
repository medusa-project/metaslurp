##
# Element archetype.
#
class Element < ApplicationRecord

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
  # @return [Element] New non-persisted AvailableElement
  #
  def self.from_json_struct(struct)
    e = Element.new
    e.update_from_json_struct(struct)
    e
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
      Element.all.where('id != ? AND index >= ?', self.id, self.index).each do |e|
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
        Element.all.order(:index).each_with_index do |element, index|
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
    if self.index_changed?
      min = [self.index_was, self.index].min
      max = [self.index_was, self.index].max
      increased = (self.index_was < self.index)

      ActiveRecord::Base.transaction do
        Element.all.where('id != ? AND index >= ? AND index <= ?', self.id, min, max).each do |e|
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
