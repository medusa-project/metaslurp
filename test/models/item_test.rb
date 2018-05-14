require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  setup do
    @instance = Item.new(id: 'cats',
                         media_type: 'image/jpeg',
                         service_key: content_services(:one).key,
                         source_id: 'cats',
                         source_uri: 'http://example.org/cats',
                         full_text: 'Lorem ipsum',
                         access_image_uri: 'http://example.org/cats/image.jpg',
                         variant: Item::Variants::ITEM)
    @instance.elements << Element.new(name: 'name', value: 'value')
    @instance.local_elements << Element.new(name: 'name', value: 'value')
  end

  # from_indexed_json()

  test 'from_indexed_json() with valid data returns an instance' do
    item = Item.from_indexed_json(
        {
            Item::IndexFields::ID => 'cats',
            '_source' => {
                Item::IndexFields::ACCESS_IMAGE_URI => 'http://example.org/cats/image.jpg',
                Item::IndexFields::FULL_TEXT => 'Lorem ipsum',
                Item::IndexFields::LAST_INDEXED => '2018-03-21T22:54:27Z',
                Item::IndexFields::MEDIA_TYPE => 'image/jpeg',
                Item::IndexFields::SERVICE_KEY => content_services(:one).key,
                Item::IndexFields::SOURCE_ID => 'cats',
                Item::IndexFields::SOURCE_URI => 'http://example.org/cats',
                Item::IndexFields::VARIANT => Item::Variants::ITEM,
                (Element::INDEX_FIELD_PREFIX + 'title') => [
                    'title 1',
                    'title 2'
                ],
                (ElementDef::INDEX_FIELD_PREFIX + 'title') => [
                    'title 1',
                    'title 2'
                ]
            }
        })
    assert_equal 'http://example.org/cats/image.jpg', item.access_image_uri
    assert_equal 'Lorem ipsum', item.full_text
    assert_equal Time.iso8601('2018-03-21T22:54:27Z'), item.last_indexed
    assert_equal 'cats', item.id
    assert_equal 'image/jpeg', item.media_type
    assert_equal content_services(:one).key, item.service_key
    assert_equal 'cats', item.source_id
    assert_equal 'http://example.org/cats', item.source_uri
    assert_equal Item::Variants::ITEM, item.variant
    assert_equal 2, item.elements.length
    assert_equal 'title', item.elements.to_a[0].name
    assert_equal 'title 1', item.elements.to_a[0].value
    assert_equal 'title', item.elements.to_a[1].name
    assert_equal 'title 2', item.elements.to_a[1].value
  end

  # from_json()

  test 'from_json() with valid data returns an instance' do
    item = Item.from_json(
        {
            'class': Item::Variants::ITEM,
            'id': 'cats',
            'media_type': 'image/jpeg',
            'service_key': content_services(:one).key,
            'source_id': 'cats',
            'source_uri': 'http://example.org/cats',
            'full_text': 'Lorem ipsum',
            'access_image_uri': 'http://example.org/cats/image.jpg',
            'elements': [
                'name': 'name',
                'value': 'value'
            ]
        })
    assert_equal Item::Variants::ITEM, item.variant
    assert_equal 'cats', item.id
    assert_equal 'Lorem ipsum', item.full_text
    assert_equal 'image/jpeg', item.media_type
    assert_equal content_services(:one).key, item.service_key
    assert_equal 'cats', item.source_id
    assert_equal 'http://example.org/cats', item.source_uri
    assert_equal 'http://example.org/cats/image.jpg', item.access_image_uri
    assert_equal 1, item.elements.length
    assert_equal 'name', item.elements.to_a[0].name
    assert_equal 'value', item.elements.to_a[0].value
  end

  test 'from_json() with invalid data raises an error' do
    assert_raises ArgumentError do
      Element.from_json({ 'cats': 'cats', 'dogs': 'dogs' })
    end
  end

  # initialize()

  test 'initialize() works' do
    item = Item.new(id: 'cats',
                    source_uri: 'http://example.org/cats')
    assert_equal 'cats', item.id
    assert_equal 'http://example.org/cats', item.source_uri
  end

  # ==()

  test '==() works with equal instance' do
    item2 = Item.new(id: 'cats')
    assert_equal(@instance, item2)
  end

  test '==() works with unequal instance' do
    item2 = Item.new(id: 'cats2')
    assert_not_equal(@instance, item2)
  end

  # as_indexed_json()

  test 'as_indexed_json() works' do
    struct = @instance.as_indexed_json
    assert_equal @instance.access_image_uri,
                 struct[Item::IndexFields::ACCESS_IMAGE_URI]
    assert_equal @instance.full_text,
                 struct[Item::IndexFields::FULL_TEXT]
    assert_not_empty struct[Item::IndexFields::LAST_INDEXED]
    assert_equal @instance.media_type,
                 struct[Item::IndexFields::MEDIA_TYPE]
    assert_equal @instance.service_key,
                 struct[Item::IndexFields::SERVICE_KEY]
    assert_equal @instance.source_id,
                 struct[Item::IndexFields::SOURCE_ID]
    assert_equal @instance.source_uri,
                 struct[Item::IndexFields::SOURCE_URI]
    assert_equal @instance.variant,
                 struct[Item::IndexFields::VARIANT]
  end

  # as_json()

  test 'as_json() works' do
    struct = @instance.as_json
    assert_equal Item::Variants::ITEM, struct['class']
    assert_equal 'cats', struct['id']
    assert_equal 'Lorem ipsum', struct['full_text']
    assert_equal 'image/jpeg', struct['media_type']
    assert_equal content_services(:one).key, struct['service_key']
    assert_equal 'cats', struct['source_id']
    assert_equal 'http://example.org/cats', struct['source_uri']
    assert_equal 'http://example.org/cats/image.jpg', struct['access_image_uri']
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

  # element()

  test 'element() returns an element if available' do
    assert_equal 'value', @instance.element(:name).value
  end

  test 'element() returns nil for an unavailable element' do
    assert_nil @instance.element(:bogus)
  end

  # save()

  test 'save() works' do
    client = ElasticsearchClient.instance
    index = ElasticsearchIndex.latest(Item::ELASTICSEARCH_INDEX)
    begin
      client.delete_index(index.name) if client.index_exists?(index.name)

      assert !client.get_document(index.name,
                                  Item::ELASTICSEARCH_TYPE,
                                  @instance.id)
      @instance.save

      assert client.get_document(index.name,
                                 Item::ELASTICSEARCH_TYPE,
                                 @instance.id)
    ensure
      client.delete_index(index.name)
    end
  end

  # to_s()

  test 'to_s() works' do
    assert_equal @instance.id, @instance.to_s
  end

  # validate()

  test 'validate() returns for valid instance' do
    @instance.validate
  end

  test 'validate() raises error for missing id' do
    @instance.id = ''
    assert_raises ArgumentError do
      @instance.validate
    end
  end

  test 'validate() raises error for invalid id' do
    @instance.id = 'cats/dogs'
    assert_raises ArgumentError do
      @instance.validate
    end
  end

  test 'validate() raises error for invalid media type' do
    @instance.media_type = 'dogs'
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

  test 'validate() raises error for missing source ID' do
    @instance.source_id = ''
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

  test 'validate() raises error for invalid variant' do
    @instance.variant = 'Dog'
    assert_raises ArgumentError do
      @instance.validate
    end
  end

end
