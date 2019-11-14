class ContentService < ApplicationRecord

  SUPPORTED_IMAGE_TYPES = %w(image/jpeg image/png image/tiff)

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
  # @see delete_all_items_async()
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
  # Invokes an ECS task to delete all items.
  #
  # @return [void]
  # @see delete_all_items()
  # @raises [RuntimeError] if not called in the production environment.
  #
  def delete_all_items_async
    unless Rails.env.production? or Rails.env.demo?
      raise "This method only works in production mode. In development, use "\
          "the items:delete_from_service rake task."
    end

    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ECS/Client.html#run_task-instance_method
    config = Configuration.instance
    ecs = Aws::ECS::Client.new(region: config.aws_region)
    args = {
        cluster: config.ecs_cluster,
        task_definition: config.metaslurp_ecs_task_definition,
        launch_type: "FARGATE",
        overrides: {
            container_overrides: [
                {
                    name: config.metaslurp_ecs_task_container,
                    command: ["bin/rails", "items:delete_from_service[#{self.key}]"]
                },
            ]
        },
        network_configuration: {
            awsvpc_configuration: {
                subnets: [config.ecs_subnet],
                security_groups: [config.ecs_security_group],
                assign_public_ip: "ENABLED"
            },
        }
    }
    ecs.run_task(args)
  end

  ##
  # Deletes items associated with the service from the index if they are older
  # than the given age in days.
  #
  # @param days [Integer]
  # @return [void]
  #
  def delete_items_older_than(days)
    query = {
        query: {
            bool: {
                must: [
                    {
                        term: {
                            Item::IndexFields::SERVICE_KEY => self.key
                        }
                    },
                    {
                        range: {
                            Item::IndexFields::LAST_INDEXED => {
                                lte: days.days.ago.iso8601
                            }
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
    # N.B.: Multi-threaded harvesting is one of metaslurper's features, but
    # having more than four or so threads (across all concurrent harvests)
    # POSTing data back to the application at once can lead to write-block
    # exceptions in Elasticsearch. The number of threads here is minimized in
    # order to go easy on our computing resources and increase the number of
    # possible concurrent harvests.
    command = ['java', '-jar', 'metaslurper.jar',
               '-source', self.key,
               '-sink', 'metaslurp',
               '-log_level', Rails.env.production? ? 'info' : 'debug',
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

    if harvest.max_num_items.to_i > 0
      command << '-max_entities'
      command << harvest.max_num_items
    end

    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/ECS/Client.html#run_task-instance_method
    config = Configuration.instance
    ecs = Aws::ECS::Client.new(region: config.aws_region)
    args = {
        cluster: config.ecs_cluster,
        task_definition: config.metaslurper_ecs_task_definition,
        launch_type: 'FARGATE',
        overrides: {
            container_overrides: [
                {
                    name: 'metaslurper',
                    command: command,
                    # Additive environment variable overrides to pass to
                    # metaslurper.
                    # Technically these aren't needed because the same info
                    # is already present in the task definition. It might be
                    # better to move all of that into this application's
                    # credentials, but that can wait for a rainy day.
                    environment: [
                        {
                            name: 'SERVICE_SINK_METASLURP_ENDPOINT',
                            value: config.root_url
                        },
                        {
                            name: 'SERVICE_SINK_METASLURP_USERNAME',
                            value: 'machine_user'
                        },
                        {
                            name: 'SERVICE_SINK_METASLURP_SECRET',
                            value: User.find_by_username('machine_user').api_key
                        },
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
                subnets: [config.ecs_subnet],
                security_groups: [config.ecs_security_group],
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
