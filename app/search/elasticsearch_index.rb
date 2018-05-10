##
# Encapsulates an Elasticsearch index.
#
# # Schemas
#
# Elasticsearch index schemas can't be changed in place (and that's probably
# bad practice anyway), so when a change is needed, a new index must be
# created and populated with documents; and then the "current" alias(es)
# changed to point to the new indexes.
#
# Index schemas are defined in `app/search/schemas`. There is one entity per
# index and one schema file per index per version.
#
# # Migration
#
# 1. Define the new schemas in `app/search/schemas`
# 2. Create them: `bin/rails elasticsearch:indexes:create_latest`
# 3. Populate them
# 4. Migrate to them: `bin/rails elasticsearch:indexes:migrate`
#
# @see: https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html
#
class ElasticsearchIndex

  ALL_INDEX_TYPES = [ Item::ELASTICSEARCH_INDEX ]
  # Prefixed to all index names used by the application.
  INDEX_NAME_PREFIX = 'metaslurp'
  SEARCH_ALL_FIELD = 'search_all'

  ##
  # Directory containing index schemas. Each version is in a separate file.
  # The number in the filename is the schema version.
  #
  SCHEMAS_DIR = File.join(Rails.root, 'app', 'search', 'schemas')

  @@logger = Rails.logger

  attr_accessor :type, :version

  ##
  # @param type [String] Type name.
  # @return [ElasticsearchIndex]
  #
  def self.current(type)
    build_index(type, current_version)
  end

  ##
  # @return [Integer]
  #
  def self.current_version
    Option::integer(Option::Keys::ELASTICSEARCH_INDEX_VERSION) || 0
  end

  ##
  # @param type [String] Type name.
  # @return [ElasticsearchIndex]
  #
  def self.latest(type)
    build_index(type, latest_version)
  end

  ##
  # @return [Integer]
  #
  def self.latest_version
    schema_versions.last
  end

  ##
  # Removes the current-aliases from all current indexes and adds them to the
  # latest indexes.
  #
  # @return [void]
  #
  def self.migrate_to_latest
    current_ver = current_version
    latest_ver = latest_version

    @@logger.info("ElasticsearchIndex.migrate_to_latest(): "\
      "current version: #{current_ver}; "\
      "latest version: #{latest_ver}")

    client = ElasticsearchClient.instance

    ActiveRecord::Base.transaction do
      ALL_INDEX_TYPES.each do |type|
        current_index = current(type)
        latest_index = latest(type)
        begin
          client.delete_index_alias(current_index.name,
                                    current_index.current_alias_name)
        rescue IOError => e
          raise e unless e.message.include?('aliases_not_found_exception')
        end

        puts latest_index.name
        puts latest_index.current_alias_name
        client.create_index_alias(latest_index.name,
                                  latest_index.current_alias_name)

        Option.set(Option::Keys::ELASTICSEARCH_INDEX_VERSION, latest_ver)

        @@logger.info("ElasticsearchIndex.migrate_to_latest(): "\
        "now using version #{latest_ver}")
      end
    end
  end

  ##
  # @return [Enumerable<Integer>] Schema versions in order from earliest to
  #                               latest.
  #
  def self.schema_versions
    Dir.entries(SCHEMAS_DIR)
        .select{ |e| e.match(/[\d+].yml/) }
        .map{ |e| e.gsub(/[^\d+]/, '').to_i }
        .uniq
        .sort
  end

  def ==(obj)
    obj.object_id == self.object_id ||
        (obj.kind_of?(ElasticsearchIndex) and obj.name == self.name)
  end

  ##
  # @return [String] Name of the index's "current" alias, whether or not it
  #                  has one or is current.
  #
  def current_alias_name
    sprintf('%s_current_%s_%s', INDEX_NAME_PREFIX, self.type, Rails.env)
  end

  def eql?(obj)
    self.==(obj)
  end

  def hash
    name.hash
  end

  def name
    sprintf('%s_%d_%s_%s',
            INDEX_NAME_PREFIX, self.version, self.type, Rails.env)
  end

  ##
  # @return [Hash]
  #
  def schema
    YAML.load_file(File.join(SCHEMAS_DIR, "#{self.type}-#{self.version}.yml"))
  end

  def to_s
    self.name
  end

  private

  ##
  # @param type [String] Type name.
  # @param version [Integer] Schema version.
  # @return [ElasticsearchIndex]
  #
  def self.build_index(type, version)
    index = ElasticsearchIndex.new
    index.type = type
    index.version = version
    index
  end

end