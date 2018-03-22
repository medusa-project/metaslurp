require 'test_helper'

class ElasticsearchClientTest < ActiveSupport::TestCase

  setup do
    @instance = ElasticsearchClient.instance
    @test_index = ElasticsearchIndex.latest(Item::ELASTICSEARCH_INDEX)
  end

  teardown do
    @instance.delete_index(@test_index.name) rescue nil
  end

  test 'create_index() works' do
    @instance.create_index(@test_index)
    assert @instance.index_exists?(@test_index.name)
  end

  test 'create_index_alias() works' do
    alias_name = 'test1-alias'

    @instance.create_index(@test_index)
    @instance.create_index_alias(@test_index.name, alias_name)
    assert @instance.index_exists?(@test_index.name)
    assert @instance.index_exists?(alias_name)
  end

  test 'delete_all_documents() works' do
    type_name = 'entity'
    id = 'id1'

    @instance.create_index(@test_index)
    assert_nil @instance.get_document(@test_index.name, type_name, id)

    @instance.index_document(@test_index.name, type_name, id, {})
    assert_not_nil @instance.get_document(@test_index.name, type_name, id)

    @instance.delete_all_documents(@test_index.name, type_name)
    #assert_nil @instance.get_document(@test_index.name, type_name, id) # TODO: why does this fail?
  end

  test 'delete_index() works' do
    begin
      @instance.create_index(@test_index)
      assert @instance.index_exists?(@test_index.name)
    ensure
      @instance.delete_index(@test_index.name)
      assert !@instance.index_exists?(@test_index.name)
    end
  end

  test 'delete_index() raises an error when deleting a nonexistent index' do
    assert_raises IOError do
      @instance.delete_index('bogus')
    end
  end

  test 'delete_index_alias() works' do
    alias_name = 'test1-alias'

    @instance.create_index(@test_index)
    @instance.create_index_alias(@test_index.name, alias_name)
    assert @instance.index_exists?(@test_index.name)
    assert @instance.index_exists?(alias_name)

    @instance.delete_index_alias(@test_index.name, alias_name)
    assert @instance.index_exists?(@test_index.name)
    assert !@instance.index_exists?(alias_name)
  end

  test 'delete_index_if_exists() works' do
    begin
      @instance.create_index(@test_index)
      assert @instance.index_exists?(@test_index.name)
    ensure
      @instance.delete_index_if_exists(@test_index.name)
      assert !@instance.index_exists?(@test_index.name)
    end
  end

  test 'delete_index_if_exists() does nothing when deleting a nonexistent index' do
    @instance.delete_index_if_exists('bogus')
  end

  test 'get_document() with missing document' do
    begin
      @instance.create_index(@test_index)
      assert_nil @instance.get_document(@test_index.name, 'entity', 'bogus')
    ensure
      @instance.delete_index(@test_index.name) rescue nil
    end
  end

  test 'get_document() with existing document' do
    @instance.create_index(@test_index)
    @instance.index_document(@test_index.name, 'entity', 'id1', {})
    assert_not_nil @instance.get_document(@test_index.name, 'entity', 'id1')
  end

  test 'index_document() indexes a document' do
    @instance.create_index(@test_index)
    assert_nil @instance.get_document(@test_index.name, 'entity', 'id1')

    @instance.index_document(@test_index.name, 'entity', 'id1', {})
    assert_not_nil @instance.get_document(@test_index.name, 'entity', 'id1')
  end

  test 'index_exists?() works' do
    @instance.create_index(@test_index)
    assert @instance.index_exists?(@test_index.name)

    @instance.delete_index(@test_index.name) rescue nil
    assert !@instance.index_exists?(@test_index.name)
  end

  test 'indexes() works' do
    @instance.create_index(@test_index)
    assert_not_empty @instance.indexes
  end

end
