require 'test_helper'

class ElementRelationTest < ActiveSupport::TestCase

  setup do
    config = Configuration.instance
    @index = config.opensearch_index
    setup_opensearch
    seed
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
    OpenSearchClient.instance.refresh
  end

  test 'to_a() works' do
    @instance = ElementRelation.new(ElementDef.new(name: 'subject'))
    assert_equal 2, @instance.to_a.length
  end

  test 'count() works' do
    skip # TODO: why does this fail?
    @instance = ElementRelation.new(ElementDef.new(name: 'subject')).
        aggregations(false)
    assert_equal 2, @instance.count
  end

end
