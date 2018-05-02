class ElasticsearchClient

  include Singleton

  # Field values should be truncated to this length.
  # (32766 total / 3 bytes per character)
  MAX_KEYWORD_FIELD_LENGTH = 10922

  # Default is 10,000. This should remain in sync with the same value in the
  # schema YAML.
  MAX_RESULT_WINDOW = 1000000000

  @@logger = Rails.logger

  @@http_client = Faraday.new(url: Configuration.instance.elasticsearch_endpoint)

  ##
  # @param index [ElasticsearchIndex]
  # @return [Boolean]
  # @raises [IOError]
  #
  def create_index(index)
    @@logger.info("ElasticsearchClient.create_index(): creating #{index.name}...")
    index_path = '/' + index.name

    response = @@http_client.put do |request|
      request.path = index_path
      request.body = JSON.generate(index.schema)
      request.headers['Content-Type'] = 'application/json'
    end

    if response.status == 200
      @@logger.info("ElasticsearchClient.create_index(): created #{index}")
    else
      raise IOError, "Got #{response.status} for PUT #{index_path}\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param alias_name [String]
  # @param index_name [String]
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
    response = @@http_client.post do |request|
      request.path = path
      request.body = JSON.generate(body)
      request.headers['Content-Type'] = 'application/json'
    end

    if response.status == 200
      @@logger.info("ElasticsearchClient.create_index_alias(): "\
          "#{alias_name} -> #{index_name}")
    else
      raise IOError, "Got #{response.status}:\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param index_name [String]
  # @param type [String]
  # @return [void]
  # @raises [IOError]
  #
  def delete_all_documents(index_name, type)
    @@logger.info("ElasticsearchClient.delete_all_documents(): deleting all "\
        "documents in index #{index_name}/#{type}...")
    path = sprintf('/%s/%s/_delete_by_query?conflicts=proceed',
                   index_name, type)
    body = {
        query: {
            match_all: {}
        }
    }
    response = @@http_client.post do |request|
      request.path = path
      request.body = JSON.generate(body)
      request.headers['Content-Type'] = 'application/json'
    end
    if response.status == 200
      @@logger.info("ElasticsearchClient.delete_all_documents(): all "\
          "documents deleted from #{index_name}")
    else
      raise IOError, "Got #{response.status} for POST #{uri}\n#{response.body}"
    end
  end

  ##
  # @param index [String]
  # @param query [String] JSON query string.
  # @return [String] Response body.
  #
  def delete_by_query(index, query)
    path = sprintf('/%s/_delete_by_query?pretty', index)
    @@logger.debug("ElasticsearchClient.delete_by_query(): #{path}\n    #{query}")
    response = @@http_client.post do |request|
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
    @@logger.info("ElasticsearchClient.delete_index(): deleting #{name}...")
    response = @@http_client.delete('/' + name)
    if response.status == 200
      @@logger.info("ElasticsearchClient.delete_index(): #{name} deleted")
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
    response = @@http_client.delete(path)
    if response.status == 200
      @@logger.info("ElasticsearchClient.delete_index_alias(): deleted "\
          "#{alias_name}")
    else
      raise IOError, "Got #{response.status} for DELETE #{uri}\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param name [String] Index name.
  # @return [void]
  # @raises [IOError]
  #
  def delete_index_if_exists(name)
    delete_index(name) if index_exists?(name)
  end

  ##
  # @param index_name [String]
  # @param id [String]
  # @return [Hash, nil]
  #
  def get_document(index_name, type, id)
    path = sprintf('/%s/%s/%s', index_name, type, id)
    @@logger.debug("ElasticsearchClient.get_document(): #{index_name}/#{id}")
    response = @@http_client.get(path)
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
  # @param type [String]  Type name.
  # @param id [String]    Document ID.
  # @param doc [Hash]     Hash to serialize as JSON.
  # @return [void]
  # @raises [IOError]     If Elasticsearch returns an error response.
  #
  def index_document(index, type, id, doc)
    path = sprintf('/%s/%s/%s', index, type, id)
    @@logger.debug("ElasticsearchClient.index_document(): #{index}/#{id}")
    response = @@http_client.put do |request|
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
    response = @@http_client.get('/' + name)
    response.status == 200
  end

  ##
  # @return [String] Summary of all indexes in the node.
  #
  def indexes
    response = @@http_client.get('/_aliases?pretty')
    response.body
  end

  ##
  # @param index [String]
  # @param query [String] JSON query string.
  # @return [String] Response body.
  #
  def query(index, query)
    path = sprintf('/%s/_search?pretty', index)
    @@logger.debug("ElasticsearchClient.query(): #{path}\n    #{query}")
    response = @@http_client.post do |request|
      request.path = path
      request.body = query
      request.headers['Content-Type'] = 'application/json'
    end
    response.body
  end

  private

  def endpoint
    Configuration.instance.elasticsearch_endpoint
  end

end