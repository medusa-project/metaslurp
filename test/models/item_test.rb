require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  setup do
    @instance = Item.new(index_id: 'cats',
                         service_key: content_services(:one).key,
                         source_uri: 'http://example.org/cats')
    @instance.elements << ItemElement.new(name: 'name', value: 'value')
  end

  # from_json()

  test 'from_json() with valid data returns an instance' do
    item = Item.from_json(
        {
            'index_id': 'cats',
            'service_key': content_services(:one).key,
            'source_uri': 'http://example.org/cats',
            'elements': [
                'name': 'name',
                'value': 'value'
            ]
        })
    assert_equal 'cats', item.index_id
    assert_equal content_services(:one).key, item.service_key
    assert_equal 'http://example.org/cats', item.source_uri
    assert_equal 1, item.elements.length
    assert_equal 'name', item.elements.to_a[0].name
    assert_equal 'value', item.elements.to_a[0].value
  end

  test 'from_json() with invalid data raises an error' do
    assert_raises ArgumentError do
      ItemElement.from_json({ 'cats': 'cats', 'dogs': 'dogs' })
    end
  end

  # initialize()

  test 'initialize() works' do
    item = Item.new(index_id: 'cats',
                    source_uri: 'http://example.org/cats')
    assert_equal 'cats', item.index_id
    assert_equal 'http://example.org/cats', item.source_uri
  end

  # ==()

  test '==() works with equal instance' do
    item2 = Item.new(index_id: 'cats')
    assert_equal(@instance, item2)
  end

  test '==() works with unequal instance' do
    item2 = Item.new(index_id: 'cats2')
    assert_not_equal(@instance, item2)
  end

  # as_json()

  test 'as_json() works' do
    struct = @instance.as_json
    assert_equal 'cats', struct['index_id']
    assert_equal content_services(:one).key, struct['service_key']
    assert_equal 'http://example.org/cats', struct['source_uri']
    assert_equal 1, struct['elements'].length
    assert_equal 'name', struct['elements'][0]['name']
    assert_equal 'value', struct['elements'][0]['value']
  end

  # content_service()

  test 'content_service() returns a content service when the service key is '\
  'set to an existing content service key' do
    assert_kind_of ContentService, @instance.content_service
  end

  test 'content_service() returns nil when the service key is not set' do
    @instance.service_key = nil
    assert_nil @instance.content_service
  end

  test 'content_service() returns nil when the service key is set to an '\
   'invalid value' do
    @instance.service_key = 'bogus'
    assert_nil @instance.content_service
  end

  # to_s()

  test 'to_s() works' do
    assert_equal @instance.index_id, @instance.to_s
  end

  # validate()

  test 'validate() returns for valid instance' do
    @instance.validate
  end

  test 'validate() raises error for invalid index_id' do
    @instance.index_id = ''
    assert_raises ArgumentError do
      @instance.validate
    end
  end

  test 'validate() raises error for missing service key' do
    @instance.service_key = ''
    assert_raises ArgumentError do
      @instance.validate
    end
  end

  test 'validate() raises error for invalid service key' do
    @instance.service_key = 'dogs'
    assert_raises ArgumentError do
      @instance.validate
    end
  end

  test 'validate() raises error for invalid source URI' do
    @instance.source_uri = ''
    assert_raises ArgumentError do
      @instance.validate
    end
  end

  test 'validate() raises error for empty elements' do
    @instance.elements.clear
    assert_raises ArgumentError do
      @instance.validate
    end
  end

end
