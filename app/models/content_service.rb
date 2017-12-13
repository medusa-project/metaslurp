class ContentService < ApplicationRecord

  validates :key, presence: true, length: { maximum: 20 },
            uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 200 },
            uniqueness: { case_sensitive: false }
  validates_format_of :uri, with: URI.regexp,
                      message: 'is invalid', allow_blank: true

  def to_param
    self.key
  end

  def to_s
    self.name.present? ? "#{self.name}" : "#{self.key}"
  end

end
