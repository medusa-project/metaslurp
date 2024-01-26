# frozen_string_literal: true

class ValueMapping < ApplicationRecord

  belongs_to :element_def, inverse_of: :value_mappings

  validates :source_value, presence: true

  def to_s
    "#{self.element_def}: #{self.source_value} -> #{self.local_value}"
  end

end
