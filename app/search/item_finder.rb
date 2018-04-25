##
# Provides a convenient ActiveRecord-style Builder interface for Item retrieval.
#
class ItemFinder < AbstractFinder

  def initialize
    super
    @content_service = nil
    @exclude_variants = []
    @include_variants = []
  end

  ##
  # Limits the search to a particular content service.
  #
  # @param content_service [ContentService]
  # @return [ItemFinder] self
  #
  def content_service(content_service)
    @content_service = content_service
    self
  end

  ##
  # @param variants [String] One or more `Item::Variants` constant values.
  # @return [ItemFinder] self
  #
  def exclude_variants(*variants)
    @exclude_variants = variants
    self
  end

  ##
  # @param variants [String] One or more `Item::Variants` constant values.
  # @return [ItemFinder] self
  #
  def include_variants(*variants)
    @include_variants = variants
    self
  end

  protected

  ##
  # @return [String] JSON string.
  #
  def build_query
    json = Jbuilder.encode do |j|
      j.query do
        j.bool do
          # Query
          if @query.present?
            j.must do
              # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
              j.query_string do
                j.query @query[:query]
                j.default_field @query[:field]
                j.default_operator 'AND'
                j.lenient true
                if @include_children_in_results
                  j.fields [@query[:field],
                            ItemElement.new(name: EntityElement.element_name_for_indexed_field(@query[:field])).parent_indexed_field]
                end
              end
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

          if @exclude_variants.any?
            j.must_not do
              if @exclude_variants.any?
                j.child! do
                  j.terms do
                    j.set! Item::IndexFields::VARIANT, @exclude_variants
                  end
                end
              end
            end
          end
        end
      end

      # Aggregations
      j.aggregations do
        if @aggregations
          # Facetable elements of the content service
          facetable_elements.each do |element|
            j.set! element.indexed_keyword_field do
              j.terms do
                j.set! :field, element.indexed_keyword_field
                j.size @bucket_limit
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
      if @start.present?
        j.from @start
      end

      # Limit
      if @limit.present?
        j.size @limit
      end
    end

    # For debugging
    #File.write('query.json', JSON.pretty_generate(JSON.parse(json)))
    # curl -XGET 'localhost:9200/items_development/_search?size=0&pretty' -H 'Content-Type: application/json' -d @query.json

    json
  end

  ##
  # @Override
  #
  def facetable_elements
    elements = [
        Element.new(name: Item::IndexFields::SERVICE_KEY,
                    indexed_keyword_field: Item::IndexFields::SERVICE_KEY + Element::KEYWORD_FIELD_SUFFIX,
                    label: 'Service',
                    facetable: true)
    ]
    elements + super.to_a
  end

end