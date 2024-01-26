# frozen_string_literal: true

class Boost < ApplicationRecord

  MIN_BOOST = -10
  MAX_BOOST = 10

  validates :field, presence: true, uniqueness: { case_sensitive: false }
  validates :value, presence: true, uniqueness: { case_sensitive: false }
  validates_numericality_of :boost, { greater_than_or_equal_to: MIN_BOOST,
                                      less_than_or_equal_to: MAX_BOOST,
                                      other_than: 0 }

  def to_s
    "#{self.field}: #{self.value} (#{self.boost})"
  end

end
