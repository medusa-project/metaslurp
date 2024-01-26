# frozen_string_literal: true

##
# High-level OpenSearch client.
#
class OpenSearchClient

  include Singleton

  LOGGER = CustomLogger.new(OpenSearchClient)

  # Field values should be truncated to this length.
  # (32766 total / 3 bytes per character)
  MAX_KEYWORD_FIELD_LENGTH = 10922

  # Default is 10,000. This should remain in sync with the same value in the
  # schema YAML.
  MAX_RESULT_WINDOW = 10000

  def initialize
    @http_client = Faraday.new(url: Configuration.instance.opensearch_endpoint)
  end

  ##
  # @param index_name [String] Index name.
  # @param num_shards [Integer] Supply a nonzero value to override the default
  #                             assigned by OpenSearch.
  # @return [Boolean]
  # @raises [IOError]
  #
  def create_index(index_name, num_shards: 0)
    LOGGER.info('create_index(): creating %s...', index_name)
    index_path = '/' + index_name

    schema = OpenSearchIndex::SCHEMA
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
  # @param query [String] JSON query string.
  # @param wait_for_completion [Boolean]
  # @return [String] Response body.
  #
  def delete_by_query(query:, wait_for_completion: true)
    index = Configuration.instance.opensearch_index
    path = sprintf("/%s/_delete_by_query?pretty"\
        "&conflicts=proceed"\
        "&wait_for_completion=#{wait_for_completion}"\
        "&refresh", index)
    LOGGER.debug("delete_by_query(): %s\n    %s", path, query)
    response = @http_client.post do |request|
      request.path = path
      request.body = query
      request.headers['Content-Type'] = 'application/json'
    end
    response.body
  end

  ##
  # @param index_name [String] Index name.
  # @param raise_on_not_found [Boolean]
  # @return [Boolean]
  # @raises [IOError]
  #
  def delete_index(index_name, raise_on_not_found: true)
    LOGGER.info('delete_index(): deleting %s...', index_name)
    url = sprintf('%s/%s',
                  Configuration.instance.opensearch_endpoint,
                  index_name)
    response = @http_client.delete(url, nil,
                                   'Content-Type': 'application/json')
    if response.status == 200
      LOGGER.info('delete_index(): deleted %s', index_name)
    elsif response.status != 404 || (response.status == 404 && raise_on_not_found)
      raise IOError, "Got HTTP #{response.status} for #{index_name}"
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
  # @param id [String]
  # @return [void]
  #
  def delete_task(id)
    path     = sprintf('/_tasks/%s', id)
    response = @http_client.delete(path)
    if response.status == 200
      LOGGER.info('delete_task(): deleted task %s', id)
    else
      raise IOError, "Got #{response.status} for DELETE #{path}\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param id [String]
  # @return [Hash, nil]
  #
  def get_document(id)
    index_name = ::Configuration.instance.opensearch_index
    path = sprintf('/%s/_doc/%s', index_name, id)
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
  # @param id [String]
  # @return [Hash, nil]
  #
  def get_task(id)
    path     = sprintf('/_tasks/%s?pretty', id)
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
  # @raises [IOError]     If OpenSearch returns an error response.
  #
  def index_document(index, id, doc)
    path = sprintf('/%s/_doc/%s', index, id)
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
    index  = config.opensearch_index
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
  # @return [void]
  #
  def refresh
    index = ::Configuration.instance.opensearch_index
    path = sprintf('/%s/_refresh?pretty', index)
    @http_client.post do |request|
      request.path = path
      request.headers['Content-Type'] = 'application/json'
    end
  end

  ##
  # @param from_index [String]
  # @param to_index [String]
  # @param async [Boolean]
  #
  def reindex(from_index, to_index, async: true)
    path = "/_reindex?wait_for_completion=#{!async}&pretty"
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
    Configuration.instance.opensearch_endpoint
  end

end