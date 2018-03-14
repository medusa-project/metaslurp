##
# Maps an element in a ContentService to a local Element.
#
class ElementMapping < ApplicationRecord

  belongs_to :content_service, inverse_of: :element_mappings, touch: true
  belongs_to :element, inverse_of: :element_mappings, optional: true

  validates :source_name, presence: true, length: { maximum: 200 }

  def to_s
    "#{self.source_name} -> #{self.element&.name}"
  end

end
