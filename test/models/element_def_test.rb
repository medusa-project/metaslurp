require 'test_helper'

class ElementDefTest < ActiveSupport::TestCase

  setup do
    @instance = element_defs(:title)
    assert @instance.validate
  end

  # indexed_field()

  test 'indexed_field() returns the correct value when the data type is DATE' do
    @instance.data_type = ElementDef::DataType::DATE
    assert_equal 'd_title', @instance.indexed_field
  end

  test 'indexed_field() returns the correct value when the data type is STRING' do
    assert_equal 'e_title', @instance.indexed_field
  end

  # indexed_keyword_field()

  test 'indexed_keyword_field() returns the correct value when the data type is DATE' do
    @instance.data_type = ElementDef::DataType::DATE
    assert_equal 'd_title', @instance.indexed_keyword_field
  end

  test 'indexed_keyword_field() returns the correct value when the data type is STRING' do
    assert_equal 'e_title.keyword', @instance.indexed_keyword_field
  end

  # indexed_sort_field()

  test 'indexed_sort_field() returns the correct value when the data type is DATE' do
    @instance.data_type = ElementDef::DataType::DATE
    assert_equal 'd_title', @instance.indexed_sort_field
  end

  test 'indexed_sort_field() returns the correct value when the data type is STRING' do
    assert_equal 'e_title.sort', @instance.indexed_sort_field
  end

  # to_s()

  test 'to_s() returns the correct string' do
    assert_equal 'title', @instance.to_s
  end

  # validate()

  test 'validate() requires unique names' do
    ElementDef.all.each_with_index do |e, i|
      e.name = 'title'
      if i == 0
        e.save!
      else
        assert_raises ActiveRecord::RecordInvalid do
          e.save!
        end
      end
    end
  end

end
