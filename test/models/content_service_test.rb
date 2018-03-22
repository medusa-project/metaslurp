require 'test_helper'

class ContentServiceTest < ActiveSupport::TestCase

  setup do
    @instance = content_services(:one)
  end

  # element_for_source_element()

  test 'element_for_source_element() with existing mapping' do
    src_elem = SourceElement.new
    src_elem.name = 'title'
    assert_equal 'title', @instance.element_for_source_element(src_elem).name
  end

  test 'element_for_source_element() with no mapping' do
    src_elem = SourceElement.new
    src_elem.name = 'bogus'
    assert_nil @instance.element_for_source_element(src_elem)
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
