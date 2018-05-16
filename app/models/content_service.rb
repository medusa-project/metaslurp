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
  # Deletes all items associated with the service from the index.
  #
  # @return [void]
  # @see send_delete_all_items_sns()
  #
  def delete_all_items
    index = ElasticsearchIndex.current(Item::ELASTICSEARCH_INDEX)
    query = sprintf('{
        "query": {
          "bool": {
            "filter": [
              {
                "term": {
                  "%s":"%s"
                }
              }
            ]
          }
        }
      }', Item::IndexFields::SERVICE_KEY + '.keyword', self.key)

    ElasticsearchClient.instance.delete_by_query(index, query)
  end

  ##
  # @param element [Element]
  # @return [ElementDef]
  #
  def element_def_for_element(element)
    self.element_mappings.
        select{ |m| m.source_name == element.name}.first&.element_def
  end

  ##
  # @return [Integer] The number of items contained in the service. The result
  #                   is cached.
  #
  def num_items
    if @num_items < 0
      @num_items = ItemFinder.new.
          content_service(self).
          aggregations(false).
          include_variants(Item::Variants::ITEM).
          limit(0).
          count
    end
    @num_items
  end

  ##
  # Sends an SNS message to delete all items, which will be picked up by an
  # AWS Lambda function.
  #
  # @return [void]
  # @see delete_all_items()
  #
  def send_delete_all_items_sns
    sns = Aws::SNS::Resource.new(region: 'us-east-2') # TODO: don't hard-code this
    topic = sns.topic('arn:aws:sns:us-east-2:974537181275:metaslurp-dev') # TODO: don't hard-code this
    attrs = {
        'Message': 'purgeDocuments',
        'MessageAttributes': {
            'IndexName': {
                'Type': 'String',
                'Value': ElasticsearchIndex::current(Item::ELASTICSEARCH_INDEX)
            },
            'FieldName': {
                'Type': 'String',
                'Value': Item::IndexFields::SERVICE_KEY
            },
            'FieldValue': {
                'Type': 'String',
                'Value': self.key
            }
        }
    }
    topic.publish(attrs)
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
  # @param item_elements [Enumerable<Element>]
  # @return [void]
  #
  def update_element_mappings(item_elements)
    return if item_elements.empty?

    mappings = self.element_mappings

    item_elements.each do |item_element|
      unless mappings.find{ |m| m.source_name == item_element.name }
        mappings.build(source_name: item_element.name)
      end
    end
    self.save! rescue PG::UniqueViolation # this is OK as this method is not thread-safe
  end

end
