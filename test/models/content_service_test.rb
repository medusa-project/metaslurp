require 'test_helper'

class ContentServiceTest < ActiveSupport::TestCase

  setup do
    @instance = content_services(:one)
  end

  # element_def_for_element()

  test 'element_def_for_element() with existing mapping' do
    src_elem = Element.new
    src_elem.name = 'title'
    assert_equal 'title', @instance.element_def_for_element(src_elem).name
  end

  test 'element_def_for_element() with no mapping' do
    src_elem = Element.new
    src_elem.name = 'bogus'
    assert_nil @instance.element_def_for_element(src_elem)
  end

  # send_delete_all_items_sns()

  test 'send_delete_all_items_sns raises an error' do
    assert_raises RuntimeError do
      @instance.send_delete_all_items_sns
    end
  end

  test 'send_delete_all_items_sns works' do
    # TODO: write this
  end

  # update_element_mappings()

  test 'update_element_mappings() works' do
    mapping_count = @instance.element_mappings.count

    @instance.update_element_mappings([
        Element.new(name: 'title', value: 'a'),
        Element.new(name: 'will_be_new', value: 'b')
    ])

    assert_equal mapping_count + 1, @instance.element_mappings.count
  end

end
