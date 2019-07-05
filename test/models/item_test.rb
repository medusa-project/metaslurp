require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  setup do
    @instance = Item.new(id: 'cats',
                         harvest_key: harvests(:new).key,
                         media_type: 'image/jpeg',
                         parent_id: 'felines',
                         service_key: content_services(:one).key,
                         source_id: 'cats',
                         source_uri: 'http://example.org/cats',
                         full_text: 'Lorem ipsum',
                         variant: Item::Variants::ITEM)
    @instance.images << Image.new(crop: :full,
                                  size: 256,
                                  uri: 'http://example.org/cats/image-256.jpg',
                                  master: false)
    @instance.images << Image.new(crop: :full,
                                  size: :full,
                                  uri: 'http://example.org/cats/image-512.jpg',
                                  master: true)
    @instance.elements << SourceElement.new(name: 'title',
                                            value: 'value')
    @instance.elements << SourceElement.new(name: 'date',
                                            value: '2018-05-01T22:16:06Z')
    @instance.local_elements << LocalElement.new(name: 'title',
                                                 value: 'value')
    @instance.local_elements << LocalElement.new(name: 'date',
                                                 value: '2018-05-01T22:16:06Z')
  end

  # from_indexed_json()

  test 'from_indexed_json with valid data returns an instance' do
    item = Item.from_indexed_json(
        {
            Item::IndexFields::ID => 'cats',
            '_source' => {
                Item::IndexFields::IMAGES => [
                    {
                        'crop'   => 'full',
                        'size'   => 256,
                        'uri'    => 'http://example.org/cats/image-256.jpg',
                        'master' => false
                    },
                    {
                        'crop'   => 'full',
                        'size'   => 512,
                        'uri'    => 'http://example.org/cats/image-512.jpg',
                        'master' => true
                    }
                ],
                Item::IndexFields::FULL_TEXT    => 'Lorem ipsum',
                Item::IndexFields::HARVEST_KEY  => harvests(:new).key,
                Item::IndexFields::LAST_INDEXED => '2018-03-21T22:54:27Z',
                Item::IndexFields::MEDIA_TYPE   => 'image/jpeg',
                Item::IndexFields::PARENT_ID    => 'felines',
                Item::IndexFields::SERVICE_KEY  => content_services(:one).key,
                Item::IndexFields::SOURCE_ID    => 'cats',
                Item::IndexFields::SOURCE_URI   => 'http://example.org/cats',
                Item::IndexFields::VARIANT      => Item::Variants::ITEM,
                (SourceElement::RAW_INDEX_PREFIX + 'title') => [
                    'title 1',
                    'title 2'
                ],
                (LocalElement::TEXT_INDEX_PREFIX + 'title') => [
                    'title 1',
                    'title 2'
                ],
                (LocalElement::DATE_INDEX_PREFIX + 'date') => '1987-01-01T00:00:00Z'
            }
        })
    assert_equal 'Lorem ipsum', item.full_text
    assert_equal harvests(:new).key, item.harvest_key
    assert_equal Time.iso8601('2018-03-21T22:54:27Z'), item.last_indexed
    assert_equal 'cats', item.id
    assert_equal 'image/jpeg', item.media_type
    assert_equal 'felines', item.parent_id
    assert_equal content_services(:one).key, item.service_key
    assert_equal 'cats', item.source_id
    assert_equal 'http://example.org/cats', item.source_uri
    assert_equal Item::Variants::ITEM, item.variant
    assert_equal 2, item.elements.length

    expected = Set.new
    expected << Image.new(crop: :full,
                          size: 256,
                          uri: 'http://example.org/cats/image-256.jpg',
                          master: false)
    expected << Image.new(crop: :full,
                          size: :full,
                          uri: 'http://example.org/cats/image-512.jpg',
                          master: true)
    assert_equal expected, item.images

    src_titles = item.elements.select{ |e| e.name == 'title' }
    assert_equal 'title 1', src_titles[0].value
    assert_equal 'title 2', src_titles[1].value

    local_titles = item.local_elements.select{ |e| e.name == 'title' }
    assert_equal 'title 1', local_titles[0].value
    assert_equal 'title 2', local_titles[1].value

    local_date = item.local_elements.find{ |e| e.name == 'date' }
    assert_equal '1987-01-01T00:00:00Z', local_date.value
  end

  # from_json()

  test 'from_json() with valid data returns an instance' do
    item = Item.from_json(
        {
            'variant': Item::Variants::ITEM,
            'id': 'cats',
            'harvest_key': harvests(:new).key,
            'media_type': 'image/jpeg',
            'parent_id': 'felines',
            'service_key': content_services(:one).key,
            'source_id': 'cats',
            'source_uri': 'http://example.org/cats',
            'full_text': 'Lorem ipsum',
            'images': [
                {
                    'crop'   => 'full',
                    'size'   => 256,
                    'uri'    => 'http://example.org/cats/image-256.jpg',
                    'master' => false
                },
                {
                    'crop'   => 'full',
                    'size'   => 'full',
                    'uri'    => 'http://example.org/cats/image-512.jpg',
                    'master' => true
                }
            ],
            'elements': [
                {
                    'name': 'name',
                    'value': 'value'
                }
            ]
        })
    assert_equal Item::Variants::ITEM, item.variant
    assert_equal 'cats', item.id
    assert_equal 'Lorem ipsum', item.full_text
    assert_equal harvests(:new).key, item.harvest_key
    assert_equal 'image/jpeg', item.media_type
    assert_equal content_services(:one).key, item.service_key
    assert_equal 'cats', item.source_id
    assert_equal 'http://example.org/cats', item.source_uri
    assert_equal 1, item.elements.length

    expected = Set.new
    expected << Image.new(crop: :full,
                          size: 256,
                          uri: 'http://example.org/cats/image-256.jpg',
                          master: false)
    expected << Image.new(crop: :full,
                          size: :full,
                          uri: 'http://example.org/cats/image-512.jpg',
                          master: true)
    assert_equal expected, item.images

    element = item.elements.to_a[0]
    assert_equal 'name', element.name
    assert_equal 'value', element.value
  end

  test 'from_json() with invalid data raises an error' do
    assert_raises ArgumentError do
      Item.from_json('cats': 'cats', 'dogs': 'dogs')
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

  test 'as_indexed_json works' do
    struct = @instance.as_indexed_json
    assert_equal @instance.full_text,
                 struct[Item::IndexFields::FULL_TEXT]
    assert_equal @instance.harvest_key,
                 struct[Item::IndexFields::HARVEST_KEY]
    assert_not_empty struct[Item::IndexFields::LAST_INDEXED]
    assert_equal @instance.media_type,
                 struct[Item::IndexFields::MEDIA_TYPE]
    assert_equal @instance.parent_id,
                 struct[Item::IndexFields::PARENT_ID]
    assert_equal @instance.service_key,
                 struct[Item::IndexFields::SERVICE_KEY]
    assert_equal @instance.source_id,
                 struct[Item::IndexFields::SOURCE_ID]
    assert_equal @instance.source_uri,
                 struct[Item::IndexFields::SOURCE_URI]
    assert_equal @instance.variant,
                 struct[Item::IndexFields::VARIANT]

    expected = [
        {
            'crop'   => 'full',
            'size'   => 256,
            'uri'    => 'http://example.org/cats/image-256.jpg',
            'master' => false
        },
        {
            'crop'   => 'full',
            'size'   => 0,
            'uri'    => 'http://example.org/cats/image-512.jpg',
            'master' => true
        }
    ]
    assert_equal expected, struct[Item::IndexFields::IMAGES]

    assert_equal ['value'],
                 struct[SourceElement::RAW_INDEX_PREFIX + 'title']
    assert_equal ['2018-05-01T22:16:06Z'],
                 struct[SourceElement::RAW_INDEX_PREFIX + 'date']
    assert_equal ['value'],
                 struct[LocalElement::TEXT_INDEX_PREFIX + 'title']
    assert_equal '2018-05-01T21:06:00Z',
                 struct[LocalElement::DATE_INDEX_PREFIX + 'date']
  end

  test 'as_indexed_json respects value mappings' do
    e_def = element_defs(:title)
    mapping = e_def.value_mappings.build(element_def: e_def,
                                         source_value: 'value',
                                         local_value: 'the new value')
    mapping.save!

    struct = @instance.as_indexed_json
    assert_equal ['the new value'],
                 struct[LocalElement::TEXT_INDEX_PREFIX + 'title']
  end

  # as_json()

  test 'as_json() works' do
    struct = @instance.as_json
    assert_equal Item::Variants::ITEM, struct['variant']
    assert_equal 'cats', struct['id']
    assert_equal 'Lorem ipsum', struct['full_text']
    assert_equal harvests(:new).key, struct['harvest_key']
    assert_equal 'image/jpeg', struct['media_type']
    assert_equal 'felines', struct['parent_id']
    assert_equal content_services(:one).key, struct['service_key']
    assert_equal 'cats', struct['source_id']
    assert_equal 'http://example.org/cats', struct['source_uri']
    assert_equal 2, struct['elements'].length

    expected = [
        {
            'crop'   => 'full',
            'size'   => 256,
            'uri'    => 'http://example.org/cats/image-256.jpg',
            'master' => false
        },
        {
            'crop'   => 'full',
            'size'   => 0,
            'uri'    => 'http://example.org/cats/image-512.jpg',
            'master' => true
        }
    ]
    assert_equal expected, struct['images']

    assert_equal 'title', struct['elements'][0]['name']
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

  # date()

  test 'date() works' do
    assert_equal '2018-05-01T22:16:06Z', @instance.date.iso8601
  end

  test 'date() returns nil when there is no date element' do
    @instance.local_elements.clear
    assert_nil @instance.date
  end

  # element()

  test 'element() returns an element if available' do
    assert_equal 'value', @instance.element(:title).value
  end

  test 'element() returns nil for an unavailable element' do
    assert_nil @instance.element(:bogus)
  end

  # harvest()

  test 'harvest() returns a Harvest when the harvest key is set to an '\
  'existing harvest key' do
    assert_kind_of Harvest, @instance.harvest
  end

  test 'harvest() returns nil when the harvest key is not set' do
    @instance.harvest_key = nil
    assert_nil @instance.harvest
  end

  test 'harvest() returns nil when the harvest key is set to an invalid value' do
    @instance.harvest_key = 'bogus'
    assert_nil @instance.harvest
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

  # title()

  test 'title() returns the title element value' do
    assert_equal 'value', @instance.title
  end

  test 'title() returns a string signifier when there is no title element' do
    @instance.local_elements.clear
    assert_equal 'Untitled', @instance.title
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

  test 'validate() raises error for missing harvest key' do
    @instance.harvest_key = ''
    assert_raises ArgumentError do
      @instance.validate
    end
  end

  test 'validate() raises error for invalid harvest key' do
    @instance.harvest_key = 'dogs'
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
