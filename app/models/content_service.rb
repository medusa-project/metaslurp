class ContentService < ApplicationRecord

  has_many :element_mappings, inverse_of: :content_service
  has_many :harvests, inverse_of: :content_service

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

  def ==(other)
    other.kind_of?(ContentService) and other.key == self.key
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
  # Invokes [metaslurper](https://github.com/medusa-project/metaslurper) via
  # an AWS ECS Fargate task to harvest items.
  #
  # @return [void]
  # @raises [RuntimeError] unless Rails is in production mode.
  # @raises [RuntimeError] if a harvest of this service is already in progress.
  #
  def harvest_items_async
    raise 'This feature only works in production. In development, invoke '\
      'metaslurper from the command line instead.' unless Rails.env.production?

    if self.harvests.where(ended_at: nil).count > 0
      raise 'Another harvest of this service is currently in progress.'
    end

    # https://docs.aws.amazon.com/sdkforruby/api/Aws/ECS/Client.html#run_task-instance_method
    ecs = Aws::ECS::Client.new(region: ENV['AWS_REGION'])
    args = {
        cluster: ENV['METASLURPER_ECS_CLUSTER'],
        task_definition: ENV['METASLURPER_ECS_TASK_DEFINITION'],
        launch_type: 'FARGATE',
        overrides: {
            container_overrides: [
                {
                    name: 'metaslurper',
                    command: ['java', '-jar', 'metaslurper.jar',
                              '-source', self.key,
                              '-sink', 'metaslurp',
                              '-threads', '2']
                },
            ]
        },
        network_configuration: {
            awsvpc_configuration: {
                subnets: [ENV['METASLURPER_ECS_SUBNET']],
                security_groups: [ENV['METASLURPER_ECS_SECURITY_GROUP']],
                assign_public_ip: 'ENABLED'
            },
        }
    }
    ecs.run_task(args)
  end

  def hash
    self.key.hash
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
          exclude_variants(Item::Variants::COLLECTION).
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
  # @raises [RuntimeError] if not called in the production environment.
  #
  def send_delete_all_items_sns
    raise 'This method only works in production mode. In development, use '\
        'the items:delete_from_service rake task.' unless Rails.env.production?

    sns = Aws::SNS::Resource.new(region: ENV['AWS_REGION'])
    # https://docs.aws.amazon.com/sdkforruby/api/Aws/SNS/Topic.html#publish-instance_method
    topic = sns.topic(ENV['SNS_TOPIC_ARN'])
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
