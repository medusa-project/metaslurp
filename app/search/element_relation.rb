# frozen_string_literal: true

##
# Provides a convenient ActiveRecord-style Builder interface for retrieval of
# element reports.
#
class ElementRelation < AbstractRelation

  TSV_HEADER = %w(service_key source_id element value).join("\t")

  ##
  # @param element [ElementDef]
  #
  def initialize(element)
    super()
    @element = element
    @orders = [
        { field: Item::IndexFields::SERVICE_KEY, direction: :asc },
        { field: Item::IndexFields::SOURCE_ID, direction: :asc }
    ]
  end

  def to_a
    load
    arr = []
    field = @element.indexed_text_field
    @response_json['hits']['hits'].each do |r|
      source = r['_source']
      source[field].each do |v|
        arr << {
            service: source[Item::IndexFields::SERVICE_KEY],
            item_source_id: source[Item::IndexFields::SOURCE_ID],
            element: @element.name,
            value: v
        }
      end
    end
    arr
  end

  protected

  ##
  # @return [String] JSON string.
  #
  def build_query
    Jbuilder.encode do |j|
      j.query do
        j.bool do
          j.must do
            j.query_string do
              j.query "#{@element.indexed_text_field}:*"
            end
          end

          if @content_service
            j.filter do
              j.child! do
                j.term do
                  j.set! Item::IndexFields::SERVICE_KEY, @content_service.key
                end
              end
            end
          end
        end
      end

      j.sort do
        @orders.each do |order|
          j.set! order[:field] do
            j.order order[:direction]
            j.unmapped_type 'keyword'
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
  end

end