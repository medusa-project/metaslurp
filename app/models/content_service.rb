class ContentService < ApplicationRecord

  SUPPORTED_IMAGE_TYPES = %w(image/jpeg image/png image/tiff)

  has_many :element_mappings, inverse_of: :content_service
  has_many :harvests, inverse_of: :content_service
  has_one_attached :representative_image

  validates :key, presence: true, length: { maximum: 20 },
            uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 200 },
            uniqueness: { case_sensitive: false }
  validates_format_of :uri, with: URI.regexp,
                      message: 'is invalid', allow_blank: true
  validate :representative_image_type

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
    query = {
        query: {
            bool: {
                filter: [
                    {
                        term: {
                            Item::IndexFields::SERVICE_KEY => self.key
                        }
                    }
                ]
            }
        }
    }
    ElasticsearchClient.instance.delete_by_query(
        ElasticsearchIndex.current(Item::ELASTICSEARCH_INDEX),
        JSON.generate(query))
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
  # @param harvest [Harvest]
  # @return [void]
  # @raises [RuntimeError] if a harvest of this service is already in progress,
  #                        or if an incremental harvest is requested but a full
  #                        harvest hasn't been completed yet.
  #
  def harvest_items_async(harvest)
    unless Rails.env.production? or Rails.env.demo?
      raise 'This feature only works in production. '\
        'In development, invoke the harvester from the command line instead.'
    end

    if self.harvests.where(ended_at: nil).where('key != ?', harvest.key).count > 0
      raise 'Another harvest of this service is currently in progress.'
    end

    # https://github.com/medusa-project/metaslurper
    command = ['java', '-jar', 'metaslurper.jar',
               '-source', self.key,
               '-sink', 'metaslurp',
               '-log_level', 'info',
               '-threads', '2']
    # If the harvest is incremental, and this service has already been
    # harvested successfully, send the -incremental argument to the harvester
    # with the last successful harvest's ending epoch time.
    if harvest.incremental
      # Use created_at instead of ended_at because technically some content
      # could have changed between the two times.
      if self.last_completed_harvest&.created_at
        command << '-incremental'
        command << self.last_completed_harvest.created_at.to_i.to_s
      else
        raise 'Can\'t harvest this service incrementally until a full '\
            'harvest has been completed.'
      end
    end

    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ECS/Client.html#run_task-instance_method
    config = Configuration.instance
    ecs = Aws::ECS::Client.new(region: config.aws_region)
    args = {
        cluster: config.metaslurper_ecs_cluster,
        task_definition: config.metaslurper_ecs_task_definition,
        launch_type: 'FARGATE',
        overrides: {
            container_overrides: [
                {
                    name: 'metaslurper',
                    command: command,
                    environment: [ # this is an additive override
                        {
                            name: 'SERVICE_SINK_METASLURP_HARVEST_KEY',
                            value: harvest.key
                        }
                    ]
                },
            ]
        },
        network_configuration: {
            awsvpc_configuration: {
                subnets: [config.metaslurper_ecs_subnet],
                security_groups: [config.metaslurper_ecs_security_group],
                assign_public_ip: 'ENABLED'
            },
        }
    }
    response = ecs.run_task(args)
    uuid = response.to_h[:tasks][0][:task_arn].split('/').last
    harvest.update!(ecs_task_uuid: uuid)
  end

  def hash
    self.key.hash
  end

  ##
  # @return [Harvest]
  #
  def last_completed_harvest
    self.harvests
        .where(status: Harvest::Status::SUCCEEDED)
        .order(created_at: :desc)
        .limit(1).first
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
    unless Rails.env.production? or Rails.env.demo?
      raise 'This method only works in production mode. In development, use '\
          'the items:delete_from_service rake task.'
    end

    sns = Aws::SNS::Resource.new(Configuration.instance.aws_region)
    # https://docs.aws.amazon.com/sdkforruby/api/Aws/SNS/Topic.html#publish-instance_method
    topic = sns.topic(Configuration.instance.sns_topic_arn)
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

  private

  def representative_image_type
    if representative_image.attached?
      unless SUPPORTED_IMAGE_TYPES.include?(representative_image.blob.content_type)
        representative_image.purge
        errors[:base] << 'Representative image must be a PNG or TIFF'
      end
    end
  end

end
