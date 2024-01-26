# frozen_string_literal: true

class Facet

  # @!attribute buckets
  #   @return [Array<Bucket>]
  attr_reader :buckets

  # @!attribute name Facet field
  #   @return [String]
  attr_accessor :field

  # @!attribute name Facet name a.k.a. label
  #   @return [String]
  attr_accessor :name

  def initialize
    @buckets = []
  end

end
