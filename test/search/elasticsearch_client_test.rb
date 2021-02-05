require 'test_helper'

class ElasticsearchClientTest < ActiveSupport::TestCase

  setup do
    @instance   = ElasticsearchClient.instance
    @test_index = Configuration.instance.elasticsearch_index
    @instance.delete_index(@test_index, raise_on_not_found: false)
  end

  teardown do
    @instance.delete_index(@test_index,
                           raise_on_not_found: false) rescue nil
  end

  test 'create_index() works' do
    @instance.create_index(@test_index)
    assert @instance.index_exists?(@test_index)
  end

  test 'create_index_alias() works' do
    alias_name = 'test1-alias'
    begin
      @instance.create_index(@test_index)
      @instance.create_index_alias(@test_index, alias_name)
      assert @instance.index_exists?(@test_index)
      assert @instance.index_exists?(alias_name)
    ensure
      if @instance.index_exists?(alias_name)
        @instance.delete_index_alias(@test_index, alias_name)
      end
    end
  end

  test 'delete_index() works' do
    begin
      @instance.create_index(@test_index)
      assert @instance.index_exists?(@test_index)
    ensure
      @instance.delete_index(@test_index)
      assert !@instance.index_exists?(@test_index)
    end
  end

  test 'delete_index() raises an error when deleting a nonexistent index' do
    assert_raises IOError do
      @instance.delete_index('bogus')
    end
  end

  test 'delete_index_alias() works' do
    alias_name = 'test1-alias'

    if @instance.index_exists?(@test_index)
      @instance.delete_index(@test_index)
    end
    @instance.create_index(@test_index)
    @instance.create_index_alias(@test_index, alias_name)
    assert @instance.index_exists?(@test_index)
    assert @instance.index_exists?(alias_name)

    @instance.delete_index_alias(@test_index, alias_name)
    assert @instance.index_exists?(@test_index)
    assert !@instance.index_exists?(alias_name)
  end

  test 'get_document() with missing document' do
    begin
      @instance.create_index(@test_index)
      assert_nil @instance.get_document('bogus')
    ensure
      @instance.delete_index(@test_index) rescue nil
    end
  end

  test 'get_document() with existing document' do
    @instance.create_index(@test_index)
    @instance.index_document(@test_index, 'id1', {})
    assert_not_nil @instance.get_document('id1')
  end

  test 'index_document() indexes a document' do
    if @instance.index_exists?(@test_index)
      @instance.delete_index(@test_index)
    end
    @instance.create_index(@test_index)
    assert_nil @instance.get_document('id1')

    @instance.index_document(@test_index, 'id1', {})
    assert_not_nil @instance.get_document('id1')
  end

  test 'index_exists?() works' do
    @instance.create_index(@test_index)
    assert @instance.index_exists?(@test_index)

    @instance.delete_index(@test_index) rescue nil
    assert !@instance.index_exists?(@test_index)
  end

  test 'indexes() works' do
    @instance.create_index(@test_index)
    assert_not_empty @instance.indexes
  end

end
