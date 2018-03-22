class ContentService < ApplicationRecord

  has_many :element_mappings, inverse_of: :content_service

  validates :key, presence: true, length: { maximum: 20 },
            uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 200 },
            uniqueness: { case_sensitive: false }
  validates_format_of :uri, with: URI.regexp,
                      message: 'is invalid', allow_blank: true

  ##
  # @param src_element [ItemElement]
  # @return [Element]
  #
  def element_for_source_element(src_element)
    self.element_mappings.
        select{ |m| m.source_name == src_element.name}.first&.element
  end

  def to_param
    self.key
  end

  def to_s
    self.name.present? ? "#{self.name}" : "#{self.key}"
  end

end
