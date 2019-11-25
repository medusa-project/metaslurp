require 'test_helper'

class ElasticsearchIndexTest < ActiveSupport::TestCase

  test 'current() returns a correct index' do
    Option.set(Option::Keys::ELASTICSEARCH_INDEX_VERSION, 0)

    index = ElasticsearchIndex.current('entities')
    assert_equal "#{ElasticsearchIndex::INDEX_NAME_PREFIX}_0_entities_test",
                 index.name
    assert_equal 0, index.version
    assert_not_empty index.schema
  end

  test 'latest() returns a correct index' do
    latest_version = ElasticsearchIndex.schema_versions.last
    index = ElasticsearchIndex.latest('entities')
    assert_equal "#{ElasticsearchIndex::INDEX_NAME_PREFIX}_#{latest_version}_entities_test",
                 index.name
    assert_equal latest_version, index.version
    assert_not_empty index.schema
  end

  test 'latest_version() works' do
    assert_equal ElasticsearchIndex.schema_versions.last,
                 ElasticsearchIndex.latest_version
  end

  test 'migrate_to_latest() works' do
    latest_version = ElasticsearchIndex.latest_version
    Option.set(Option::Keys::ELASTICSEARCH_INDEX_VERSION,
               latest_version - 1)

    client = ElasticsearchClient.instance
    current_index = ElasticsearchIndex.current('entities')
    latest_index = ElasticsearchIndex.latest('entities')

    if client.index_exists?(current_index.name)
      client.delete_index(current_index.name)
    end
    if client.index_exists?(latest_index.name)
      client.delete_index(latest_index.name)
    end

    begin
      client.create_index(current_index)
      client.create_index(latest_index)
      assert !client.index_exists?(latest_index.current_alias_name)

      ElasticsearchIndex.migrate_to_latest

      assert client.index_exists?(latest_index.current_alias_name)
    ensure
      client.delete_index(current_index.name) rescue nil
      client.delete_index(latest_index.name) rescue nil
    end
  end

  test 'schema_versions() works' do
    actual = ElasticsearchIndex.schema_versions
    assert actual.length > 1
    assert_equal 0, actual.first
  end

end
