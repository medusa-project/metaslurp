##
# Encapsulates an OpenSearch index.
#
# The application uses only one index. Its name is arbitrary. The application
# can be pointed directly at the index, or to an alias of the index, using the
# `opensearch_index` configuration key.
#
# # Index migration
#
# OpenSearch index schemas can't (for the most part) be changed in place, so
# when a change is needed, a new index must be created. This involves modifying
# `app/search/index_schema.yml` and running the `opensearch:indexes:create`
# rake task.
#
# Once created, it must be populated with documents. If the documents in the
# old index are compatible with the new index, then this is a simple matter of
# running the `opensearch:indexes:reindex` rake task. Otherwise, all
# content services need to be reharvested.
#
# Once the new index has been populated, either the application's
# `opensearch_index` configuration key must be updated to point to it, or
# else the index alias that that key is pointing to must be changed to point to
# the new index.
#
class OpenSearchIndex

  ##
  # Standard fields present in all documents.
  #
  class StandardFields
    ID         = '_id'
    SCORE      = '_score'
    SEARCH_ALL = 'search_all'
  end

  SCHEMA = YAML.unsafe_load_file(File.join(Rails.root, 'app', 'search', 'index_schema.yml'))

end