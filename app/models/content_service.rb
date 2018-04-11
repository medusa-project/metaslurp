class ContentService < ApplicationRecord

  has_many :element_mappings, inverse_of: :content_service

  validates :key, presence: true, length: { maximum: 20 },
            uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 200 },
            uniqueness: { case_sensitive: false }
  validates_format_of :uri, with: URI.regexp,
                      message: 'is invalid', allow_blank: true

  after_initialize :init

  def init
    @num_items = -1
  end

  ##
  # @param src_element [SourceElement]
  # @return [Element]
  #
  def element_for_source_element(src_element)
    self.element_mappings.
        select{ |m| m.source_name == src_element.name}.first&.element
  end

  ##
  # @return [Integer] The number of items contained in the service. The result
  #                   is cached.
  #
  def num_items
    if @num_items < 0
      @num_items = ItemFinder.new.
          content_service(self).
          aggregations(false).count
    end
    @num_items
  end

  def to_param
    self.key
  end

  def to_s
    self.name.present? ? "#{self.name}" : "#{self.key}"
  end

  ##
  # Adds new element mappings based on the given collection of source elements.
  # For example, if the collection contains `a`, `b`, and `c` elements, and the
  # instance already has mappings for `a` and `b`, then a `c` mapping will be
  # added.
  #
  # @param source_elements [Enumerable<SourceElement>]
  # @return [void]
  #
  def update_element_mappings(source_elements)
    return if source_elements.empty?

    mappings = self.element_mappings

    source_elements.each do |element|
      if mappings.select { |m| m.source_name == element.name }.empty?
        mappings.build(source_name: element.name)
      end
    end
    self.save!
  end

end
