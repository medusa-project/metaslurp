require 'test_helper'

class ItemFinderTest < ActiveSupport::TestCase

  setup do
    @index = ElasticsearchIndex.current(Item::ELASTICSEARCH_INDEX)
    client = ElasticsearchClient.instance
    client.create_index(@index) unless client.index_exists?(@index.name)
    seed

    @instance = ItemFinder.new
  end

  teardown do
    @instance.delete_index(@index.name) rescue nil
  end

  def seed
    item = Item.new(id: 'cats',
                    service_key: content_services(:one).key,
                    source_id: 'cats',
                    source_uri: 'http://example.org/cats',
                    access_image_uri: 'http://example.org/cats/image.jpg',
                    variant: Item::Variants::ITEM)
    item.elements << Element.new(name: 'name', value: 'value')
    item.save!
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
