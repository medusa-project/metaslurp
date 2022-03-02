require 'test_helper'

class ContentServiceTest < ActiveSupport::TestCase

  setup do
    @instance = content_services(:one)
  end

  # ==()

  test '==() returns true when given the same instance' do
    assert_equal @instance, @instance
  end

  test '==() returns true when given an instance with the same key' do
    assert_equal @instance, ContentService.new(key: @instance.key)
  end

  test '==() returns false when given an instance with a different key' do
    assert_not_equal @instance, ContentService.new(key: 'some-new-key')
  end

  test '==() returns false when given an instance of a different class' do
    assert_not_equal @instance, @instance.key
  end

  # element_def_for_element()

  test 'element_def_for_element() with existing mapping' do
    src_elem = SourceElement.new
    src_elem.name = 'title'
    assert_equal 'title', @instance.element_def_for_element(src_elem).name
  end

  test 'element_def_for_element() with no mapping' do
    src_elem = SourceElement.new
    src_elem.name = 'bogus'
    assert_nil @instance.element_def_for_element(src_elem)
  end

  # update_element_mappings()

  test 'update_element_mappings() works' do
    mapping_count = @instance.element_mappings.count

    @instance.update_element_mappings([
        SourceElement.new(name: 'title', value: 'a'),
        SourceElement.new(name: 'will_be_new', value: 'b')
    ])

    assert_equal mapping_count + 1, @instance.element_mappings.count
  end

end
