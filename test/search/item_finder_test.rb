require 'test_helper'

class ItemFinderTest < ActiveSupport::TestCase

  setup do
    config = Configuration.instance
    @index = config.elasticsearch_index
    setup_elasticsearch
    seed

    @instance = ItemFinder.new
  end

  teardown do
    ElasticsearchClient.instance.delete_index(@index)
  end

  def seed
    item = Item.new(id: 'cats',
                    service_key: content_services(:one).key,
                    source_id: 'cats',
                    source_uri: 'http://example.org/cats',
                    variant: Item::Variants::ITEM)
    item.elements << SourceElement.new(name: 'name', value: 'value')
    item.save!
    ElasticsearchClient.instance.refresh
  end

  test 'to_a() works' do
    assert_equal 1, @instance.to_a.length
  end

  test 'aggregations work when enabled' do
    @instance.aggregations(true)
    assert @instance.facets.any?
  end

  test 'aggregations are empty when disabled' do
    @instance.aggregations(false)
    assert @instance.facets.empty?
  end

  test 'count() works' do
    @instance.aggregations(false)
    assert @instance.count > 0
  end

end
