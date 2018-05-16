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
  # @param src_element [SourceElement]
  # @return [ElementDef]
  #
  def element_def_for_source_element(src_element)
    self.element_mappings.
        select{ |m| m.source_name == src_element.name}.first&.element_def
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
    # https://docs.aws.amazon.com/sdkforruby/api/Aws/SNS/Topic.html#publish-instance_method
    topic = sns.topic('arn:aws:sns:us-east-2:974537181275:metaslurp-dev') # TODO: don't hard-code this
    attrs = {
        message: 'purgeDocuments',
        message_attributes: {
            'IndexName' => {
                data_type: 'String',
                string_value: ElasticsearchIndex::current(Item::ELASTICSEARCH_INDEX).name
            },
            'FieldName' => {
                data_type: 'String',
                string_value: Item::IndexFields::SERVICE_KEY
            },
            'FieldValue' => {
                data_type: 'String',
                string_value: self.key
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
