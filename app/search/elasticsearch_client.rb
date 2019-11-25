##
# High-level Elasticsearch client.
#
class ElasticsearchClient

  include Singleton

  LOGGER = CustomLogger.new(ElasticsearchClient)

  # Field values should be truncated to this length.
  # (32766 total / 3 bytes per character)
  MAX_KEYWORD_FIELD_LENGTH = 10922

  # Default is 10,000. This should remain in sync with the same value in the
  # schema YAML.
  MAX_RESULT_WINDOW = 1000000000

  def initialize
    @http_client = Faraday.new(url: Configuration.instance.elasticsearch_endpoint)
  end

  ##
  # @param index_name [String] Index name.
  # @param num_shards [Integer] Supply a nonzero value to override the default
  #                             assigned by Elasticsearch.
  # @return [Boolean]
  # @raises [IOError]
  #
  def create_index(index_name, num_shards = 0)
    LOGGER.info('create_index(): creating %s...', index_name)
    index_path = '/' + index_name

    schema = ElasticsearchIndex::SCHEMA
    schema['settings']['number_of_shards'] = num_shards if num_shards > 0

    response = @http_client.put do |request|
      request.path = index_path
      request.body = JSON.generate(schema)
      request.headers['Content-Type'] = 'application/json'
    end

    if response.status == 200
      LOGGER.info('create_index(): created %s', index_name)
    else
      raise IOError, "Got #{response.status} for PUT #{index_path}\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param index_name [String]
  # @param alias_name [String]
  # @return [void]
  #
  def create_index_alias(index_name, alias_name)
    path = '/_aliases'
    body = {
        actions: [
            {
                add: {
                    index: index_name,
                    alias: alias_name
                }
            }
        ]
    }
    response = @http_client.post do |request|
      request.path = path
      request.body = JSON.generate(body)
      request.headers['Content-Type'] = 'application/json'
    end

    if response.status == 200
      LOGGER.info('create_index_alias(): %s -> %s', alias_name, index_name)
    else
      raise IOError, "Got #{response.status}:\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param index [String]
  # @param query [String] JSON query string.
  # @return [String] Response body.
  #
  def delete_by_query(index, query)
    path = sprintf('/%s/_delete_by_query?pretty&conflicts=proceed&refresh',
                   index)
    LOGGER.debug("delete_by_query(): %s\n    %s", path, query)
    response = @http_client.post do |request|
      request.path = path
      request.body = query
      request.headers['Content-Type'] = 'application/json'
    end
    response.body
  end

  ##
  # @param name [String] Index name.
  # @return [void]
  # @raises [IOError]
  #
  def delete_index(name)
    LOGGER.info('delete_index(): deleting %s...', name)
    response = @http_client.delete('/' + name)
    if response.status == 200
      LOGGER.info('delete_index(): %s deleted', name)
    else
      raise IOError, "Got #{response.status} for #{name}"
    end
  end

  ##
  # @param alias_name [String]
  # @return [void]
  #
  def delete_index_alias(index_name, alias_name)
    path = sprintf('/%s/_alias/%s', index_name, alias_name)
    response = @http_client.delete(path)
    if response.status == 200
      LOGGER.info('delete_index_alias(): deleted %s', alias_name)
    else
      raise IOError, "Got #{response.status} for DELETE #{path}\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param index_name [String]
  # @param id [String]
  # @return [Hash, nil]
  #
  def get_document(index_name, id)
    path = sprintf('/%s/entity/%s', index_name, id) # in ES 7, `entity` changes to `_doc`
    LOGGER.debug('get_document(): %s/%s', index_name, id)
    response = @http_client.get(path)
    case response.status
      when 200
        JSON.parse(response.body)
      when 404
        nil
      else
        raise IOError, response.body
    end
  end

  ##
  # @param index [String] Index name.
  # @param id [String]    Document ID.
  # @param doc [Hash]     Hash to serialize as JSON.
  # @return [void]
  # @raises [IOError]     If Elasticsearch returns an error response.
  #
  def index_document(index, id, doc)
    path = sprintf('/%s/entity/%s', index, id) # in ES 7, `entity` changes to `_doc`
    LOGGER.debug('index_document(): %s/%s', index, id)
    response = @http_client.put do |request|
      request.path = path
      request.body = JSON.generate(doc)
      request.headers['Content-Type'] = 'application/json'
    end
    if response.status >= 400
      raise IOError, response.body
    end
  end

  ##
  # @param name [String] Index name.
  # @return [Boolean]
  #
  def index_exists?(name)
    response = @http_client.get('/' + name)
    response.status == 200
  end

  ##
  # @return [String] Summary of all indexes in the node.
  #
  def indexes
    response = @http_client.get('/_aliases?pretty')
    response.body
  end

  ##
  # @param query [String] JSON query string.
  # @return [String] Response body.
  #
  def query(query)
    config = Configuration.instance
    index  = config.elasticsearch_index
    path   = sprintf('/%s/_search?pretty', index)
    response = @http_client.post do |request|
      request.path = path
      request.body = query
      request.headers['Content-Type'] = 'application/json'
    end

    LOGGER.debug("query(): %s\n    Request: %s\n    Response: %s",
                 path.force_encoding('UTF-8'),
                 query.force_encoding('UTF-8'),
                 response.body.force_encoding('UTF-8'))
    response.body
  end

  ##
  # Refreshes an index.
  #
  # @param index [String]
  # @return [void]
  #
  def refresh(index)
    path = sprintf('/%s/_refresh?pretty', index)
    @http_client.post do |request|
      request.path = path
      request.headers['Content-Type'] = 'application/json'
    end
  end

  ##
  # @param from_index [String]
  # @param to_index [String]
  #
  def reindex(from_index, to_index)
    path = '/_reindex'
    body = {
        source: {
            index: from_index
        },
        dest: {
            index: to_index
        }
    }
    body = JSON.generate(body)
    response = @http_client.post do |request|
      request.path = path
      request.body = body
      request.headers['Content-Type'] = 'application/json'
    end

    LOGGER.debug("reindex():\n    Request: %s\n    Response: %s",
                 body.force_encoding('UTF-8'),
                 response.body.force_encoding('UTF-8'))
    response.body
  end

  private

  def endpoint
    Configuration.instance.elasticsearch_endpoint
  end

end