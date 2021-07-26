class AbstractRelation

  attr_reader :request_json, :response_json

  def initialize
    @client = ElasticsearchClient.instance

    @aggregations    = true
    @bucket_limit    = Option::integer(Option::Keys::FACET_TERM_LIMIT) || 10
    @content_service = nil
    @excludes        = {}  # Hash<String,Object>
    @filters         = {} # Hash<String,Object>
    @limit           = ElasticsearchClient::MAX_RESULT_WINDOW
    @orders          = [] # Array<Hash<Symbol,String>> with :field and :direction keys
    @query           = nil # Hash<Symbol,String> Hash with :field and :query keys
    @start           = 0

    @loaded          = false

    @request_json    = {}
    @response_json   = {}
    @result_facets   = []
  end

  ##
  # @param boolean [Boolean] Whether to compile aggregations (for faceting) in
  #                          results. Disabling these when they are not needed
  #                          may improve performance.
  # @return [self]
  #
  def aggregations(boolean)
    @aggregations = boolean
    self
  end

  ##
  # Limits the search to a particular content service.
  #
  # @param content_service [ContentService]
  # @return [ItemRelation] self
  #
  def content_service(content_service)
    @content_service = content_service
    self
  end

  ##
  # @return [Integer]
  #
  def count
    load
    count = @response_json['hits']['total'] # ES 6.x
    if count.respond_to?(:keys)
      count = count['value'] # ES 7.x
    end
    count
  end

  ##
  # @param filters [Enumerable<String>, Hash<String,Object>, String] Enumerable
  #                of strings with colon-separated fields and values; hash of
  #                fields and values; or a colon-separated field/value string.
  # @return [self]
  #
  def facet_filters(filters)
    if filters.present?
      if filters.respond_to?(:to_unsafe_h)
        @filters = filters.to_unsafe_h
      elsif filters.respond_to?(:keys) # check if it's a hash
        @filters = filters
      elsif filters.respond_to?(:each) # check if it's an Enumerable
        filters.each do |filter|
          add_facet_filter_string(filter)
        end
      else
        add_facet_filter_string(filters)
      end
    end
    self
  end

  ##
  # @param limit [Integer] Maximum number of buckets that will be returned in a
  #                        facet.
  # @return [self]
  #
  def bucket_limit(limit)
    @bucket_limit = limit
  end

  ##
  # Like an inverse {filter}.
  #
  # @param field [String]
  # @param value [Object] Single value or an array of "OR" values.
  # @return [self]
  #
  def exclude(field, value)
    @excludes.merge!(field => value)
    self
  end

  ##
  # @return [Enumerable<Facet>] Result facets.
  #
  def facets
    load
    @result_facets
  end

  ##
  # Adds an arbitrary filter to limit results to.
  #
  # @param field [String]
  # @param value [Object] Single value or an array of "OR" values.
  # @return [self]
  #
  def filter(field, value)
    @filters.merge!(field => value)
    self
  end

  ##
  # @return [Integer]
  #
  def get_limit
    @limit
  end

  ##
  # @return [Integer]
  #
  def get_start
    @start
  end

  ##
  # @param limit [Integer]
  # @return [self]
  #
  def limit(limit)
    @limit = limit.to_i
    self
  end

  ##
  # @param orders [Enumerable<String>, Enumerable<Hash<String,Symbol>>]
  #               Enumerable of string field names and/or hashes with field
  #               name => direction pairs (`:asc` or `:desc`).
  # @return [self]
  #
  def order(orders)
    if orders.present?
      @orders = [] # reset them
      if orders.respond_to?(:keys)
        @orders << { field: orders.keys.first,
                     direction: orders[orders.keys.first] }
      else
        @orders << { field: orders.to_s, direction: :asc }
      end
    end
    self
  end

  ##
  # @return [Integer]
  #
  def page
    ((@start / @limit.to_f).ceil + 1 if @limit > 0) || 1
  end

  ##
  # Adds a query to search a particular field.
  #
  # @param field [String, Symbol] Field name
  # @param query [String]
  # @return [self]
  #
  def query(field, query)
    @query = { field: field.to_s, query: query.to_s } if query.present?
    self
  end

  ##
  # Adds a query to search all fields.
  #
  # @param query [String]
  # @return [self]
  #
  def query_all(query)
    query(ElasticsearchIndex::StandardFields::SEARCH_ALL, query)
    self
  end

  ##
  # @param start [Integer]
  # @return [self]
  #
  def start(start)
    @start = start.to_i
    self
  end

  ##
  # @return [Enumerable<Item>]
  #
  def to_a
    load
    @response_json['hits']['hits'].map{ |r| Item.from_indexed_json(r) }
  end

  protected

  def add_facet_filter_string(str)
    parts = str.split(':')
    @filters[parts[0]] = parts[1] if parts.length == 2
  end

  def facetable_elements
    ElementDef.where(facetable: true).order(:weight)
  end

  def load
    return if @loaded

    @response_json = get_response

    raise IOError, @response_json['error'] if @response_json['error']

    # Assemble the response aggregations into Facets.
    facetable_elements.each do |element|
      @response_json['aggregations']&.each do |key, agg|
        if key == element.indexed_facet_field
          facet = Facet.new
          facet.name = element.label
          facet.field = element.indexed_facet_field
          agg['buckets'].each do |es_bucket|
            bucket = Bucket.new
            bucket.name = es_bucket['key'].to_s
            if element.name == Item::IndexFields::SERVICE_KEY
              service = ContentService.find_by_key(es_bucket['key'])
              bucket.label = service&.name || 'Unknown Service'
            else
              bucket.label = es_bucket['key'].to_s
            end
            bucket.count = es_bucket['doc_count']
            bucket.facet = facet
            facet.buckets << bucket
          end
          @result_facets << facet
        end
      end
    end

    @loaded = true
  end

  private

  def get_response
    @request_json = build_query
    result = @client.query(@request_json)
    JSON.parse(result)
  end

end