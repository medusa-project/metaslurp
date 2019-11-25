require 'test_helper'

class ElementFinderTest < ActiveSupport::TestCase

  setup do
    config = Configuration.instance
    @index = config.elasticsearch_index
    client = ElasticsearchClient.instance
    client.create_index(@index) unless client.index_exists?(@index)
    seed
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
    item.elements << SourceElement.new(name: 'subject', value: 'value1')
    item.elements << SourceElement.new(name: 'subject', value: 'value2')
    item.save!
    ElasticsearchClient.instance.refresh(@index)
  end

  test 'to_a() works' do
    @instance = ElementFinder.new(ElementDef.new(name: 'subject'))
    assert_equal 2, @instance.to_a.length
  end

  test 'count() works' do
    @instance = ElementFinder.new(ElementDef.new(name: 'subject')).
        aggregations(false)
    assert_equal 2, @instance.count
  end

end
