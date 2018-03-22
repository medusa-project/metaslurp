class ElasticsearchClient

  include Singleton

  # Field values should be truncated to this length.
  # (32766 total / 3 bytes per character)
  MAX_KEYWORD_FIELD_LENGTH = 10922

  # Default is 10,000. This should remain in sync with the same value in the
  # schema YAML.
  MAX_RESULT_WINDOW = 1000000000

  @@http_client = HTTPClient.new
  @@logger = Rails.logger

  ##
  # @param index [ElasticsearchIndex]
  # @return [Boolean]
  # @raises [IOError]
  #
  def create_index(index)
    @@logger.info("ElasticsearchClient.create_index(): creating #{index.name}...")
    index_url = endpoint + '/' + index.name
    response = @@http_client.put(index_url,
                                 JSON.generate(index.schema),
                                 'Content-Type': 'application/json')
    if response.status == 200
      @@logger.info("ElasticsearchClient.create_index(): created #{index}")
    else
      raise IOError, "Got #{response.status} for PUT #{index_url}\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param alias_name [String]
  # @param index_name [String]
  # @return [void]
  #
  def create_index_alias(index_name, alias_name)
    url = endpoint + '/_aliases'
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
    response = @@http_client.post(url,
                                  JSON.generate(body),
                                  'Content-Type': 'application/json')
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
    uri = sprintf('%s/%s/%s/_delete_by_query?conflicts=proceed',
                  endpoint, index_name, type)
    body = {
        query: {
            match_all: {}
        }
    }
    response = @@http_client.post(uri,
                                  JSON.generate(body),
                                  'Content-Type': 'application/json')
    if response.status == 200
      @@logger.info("ElasticsearchClient.delete_all_documents(): all "\
          "documents deleted from #{index_name}")
    else
      raise IOError, "Got #{response.status} for POST #{uri}\n#{response.body}"
    end
  end

  ##
  # @param name [String] Index name.
  # @return [void]
  # @raises [IOError]
  #
  def delete_index(name)
    @@logger.info("ElasticsearchClient.delete_index(): deleting #{name}...")
    response = @@http_client.delete(endpoint + '/' + name)
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
    uri = sprintf('%s/%s/_alias/%s', endpoint, index_name, alias_name)
    response = @@http_client.delete(uri, nil,
                                    'Content-Type': 'application/json')
    if response.status == 200
      @@logger.info("ElasticsearchClient.delete_index_alias(): deleted "\
          "#{alias_name}")
    else
      raise IOError, "Got #{response.status} for DELETE #{uri}\n"\
          "#{JSON.pretty_generate(JSON.parse(response.body))}"
    end
  end

  ##
  # @param index_name [String]
  # @param id [String]
  # @return [Hash, nil]
  #
  def get_document(index_name, type, id)
    uri = sprintf('%s/%s/%s/%s', endpoint, index_name, type, id)
    @@logger.debug("ElasticsearchClient.get_document(): #{index_name}/#{id}")
    response = @@http_client.get(uri)
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
    url = sprintf('%s/%s/%s/%s', endpoint, index, type, id)
    @@logger.debug("ElasticsearchClient.index_document(): #{index}/#{id}")
    response = @@http_client.put(url,
                                 JSON.generate(doc),
                                 'Content-Type': 'application/json')
    if response.status >= 400
      raise IOError, response.body
    end
  end

  ##
  # @param name [String] Index name.
  # @return [Boolean]
  #
  def index_exists?(name)
    response = @@http_client.get(endpoint + '/' + name)
    response.status == 200
  end

  ##
  # @return [String] Summary of all indexes in the node.
  #
  def indexes
    response = @@http_client.get(endpoint + '/_aliases?pretty')
    response.body
  end

  ##
  # @param index [String]
  # @param query [String] JSON query string.
  # @return [String] Response body.
  #
  def query(index, query)
    url = sprintf('%s/%s/_search?size=0&pretty', endpoint, index)
    @@http_client.post(url, query).body
  end

  private

  def endpoint
    Configuration.instance.elasticsearch_endpoint
  end

end