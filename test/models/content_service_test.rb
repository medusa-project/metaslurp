require 'test_helper'

class ContentServiceTest < ActiveSupport::TestCase

  setup do
    @instance = content_services(:one)
  end

  test 'element_for_source_element with existing mapping' do
    src_elem = ItemElement.new
    src_elem.name = 'title'
    assert_equal 'title', @instance.element_for_source_element(src_elem).name
  end

  test 'element_for_source_element with no mapping' do
    src_elem = ItemElement.new
    src_elem.name = 'bogus'
    assert_nil @instance.element_for_source_element(src_elem)
  end

end
