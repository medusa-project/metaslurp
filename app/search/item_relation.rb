# frozen_string_literal: true

##
# Provides a convenient ActiveRecord-style Builder interface for [Item]
# retrieval.
#
class ItemRelation < AbstractRelation

  def initialize
    super
    @include_children = false
    @exclude_variants = []
    @include_variants = []
  end

  ##
  # @param variants [String] One or more `Item::Variants` constant values.
  # @return [ItemRelation] self
  #
  def exclude_variants(*variants)
    @exclude_variants = variants
    self
  end

  ##
  # @param bool [Boolean]
  # @return [ItemRelation] self
  #
  def include_children(bool)
    @include_children = bool
    self
  end

  ##
  # @param variants [String] One or more `Item::Variants` constant values.
  # @return [ItemRelation] self
  #
  def include_variants(*variants)
    @include_variants = variants
    self
  end

  ##
  # @return [String] JSON string.
  #
  def build_query
    Jbuilder.encode do |j|
      j.track_total_hits true
      j.query do
        j.function_score do
          j.query do
            j.bool do
              # Query
              if @query.present?
                j.must do
                  query_json(j)
                end
              end

              if @filters.any? or @content_service or @include_variants.any?
                j.filter do
                  @filters.each do |field, value|
                    j.child! do
                      if value.respond_to?(:each)
                        j.terms do
                          j.set! field, value
                        end
                      else
                        j.term do
                          j.set! field, value
                        end
                      end
                    end
                  end
                  if @content_service
                    j.child! do
                      j.term do
                        j.set! Item::IndexFields::SERVICE_KEY, @content_service.key
                      end
                    end
                  end
                  if @include_variants.any?
                    j.child! do
                      j.terms do
                        j.set! Item::IndexFields::VARIANT, @include_variants
                      end
                    end
                  end
                end
              end

              if @excludes.any? || @exclude_variants.any? || !@include_children
                j.must_not do
                  @excludes.each do |field, value|
                    j.child! do
                      if value.respond_to?(:each)
                        j.terms do
                          j.set! field, value
                        end
                      else
                        j.term do
                          j.set! field, value
                        end
                      end
                    end
                  end
                  if @exclude_variants.any?
                    j.child! do
                      j.terms do
                        j.set! Item::IndexFields::VARIANT, @exclude_variants
                      end
                    end
                  end
                  unless @include_children
                    j.child! do
                      j.exists do
                        j.field Item::IndexFields::PARENT_ID
                      end
                    end
                  end
                end
              end
            end
          end

          # Boost the relevancy of collection-variant items.
          # See: https://www.elastic.co/guide/en/opensearch/reference/current/query-dsl-function-score-query.html
          j.boost Boost::MAX_BOOST
          j.functions do
            Boost.all.each do |boost|
              j.child! do
                j.filter do
                  j.match do
                    j.set! boost.field, boost.value
                  end
                end
                j.weight boost.boost
              end
            end
          end
          j.max_boost Boost::MAX_BOOST
          j.score_mode 'max'
          j.boost_mode 'multiply'
        end
      end

      # Aggregations
      j.aggregations do
        if @aggregations
          # Facetable elements of the content service
          facetable_elements.each do |element|
            next if element.name == 'variant' && (@exclude_variants.present? || @include_variants.present?)

            j.set! element.indexed_facet_field do
              j.terms do
                j.set! :field, element.indexed_facet_field
                case element.facet_order
                when ElementDef::FacetOrder::ALPHANUMERIC
                  j.size AGGREGATION_ALPHANUMERIC_BUCKET_LIMIT
                  j.order do
                    j.set! :_key, "asc"
                  end
                else
                  j.size AGGREGATION_COUNT_BUCKET_LIMIT
                end
              end
            end
          end
        end
      end

      # Ordering
      if @orders.any?
        j.sort do
          @orders.each do |order|
            j.set! order[:field] do
              j.order order[:direction]
              j.unmapped_type 'keyword'
            end
          end
        end
      end

      # Start
      if @start != 0
        j.from @start
      end

      # Limit
      if @limit.present?
        j.size @limit
      end
    end
  end

  private

  def query_json(j)
    j.simple_query_string do
      query = @query[:query]
      query = '*' if query.blank?
      j.query query
      j.fields [OpenSearchIndex::StandardFields::SEARCH_ALL]
      j.flags 'NONE'
      j.default_operator 'AND'
      j.lenient true
    end
    j
  end

end