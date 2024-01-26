# frozen_string_literal: true

##
# Maps an element in a ContentService to a local ElementDef.
#
class ElementMapping < ApplicationRecord

  belongs_to :content_service, inverse_of: :element_mappings, touch: true
  belongs_to :element_def, inverse_of: :element_mappings, optional: true

  validates :source_name, presence: true, length: { maximum: 200 }

  def to_s
    "#{self.source_name} -> #{self.element_def&.name || '(unmapped)'}"
  end

end
