require 'test_helper'

class ElementDefTest < ActiveSupport::TestCase

  setup do
    @instance = element_defs(:title)
    assert @instance.validate
  end

  # destroy()

  test 'destroy() does not allow system-required elements to be destroyed' do
    assert_raises ActiveRecord::RecordNotDestroyed do
      @instance.destroy!
    end
  end

  # indexed_date_field()

  test 'indexed_date_field() returns the correct value when the data type is DATE' do
    @instance.data_type = ElementDef::DataType::DATE
    assert_equal 'local_date_title', @instance.indexed_date_field
  end

  test 'indexed_date_field() returns the correct value when the data type is STRING' do
    assert_raises do
      assert_equal 'local_text_title', @instance.indexed_date_field
    end
  end

  # indexed_facet_field()

  test 'indexed_facet_field() returns the correct value when the data type is DATE' do
    @instance.data_type = ElementDef::DataType::DATE
    assert_equal 'local_date_title', @instance.indexed_facet_field
  end

  test 'indexed_facet_field() returns the correct value when the data type is STRING' do
    assert_equal 'local_facet_title', @instance.indexed_facet_field
  end

  # indexed_sort_field()

  test 'indexed_sort_field() returns the correct value when the data type is DATE' do
    @instance.data_type = ElementDef::DataType::DATE
    assert_equal 'local_date_title', @instance.indexed_sort_field
  end

  test 'indexed_sort_field() returns the correct value when the data type is STRING' do
    assert_equal 'local_sort_title', @instance.indexed_sort_field
  end

  # to_s()

  test 'to_s() returns the correct string' do
    assert_equal 'title', @instance.to_s
  end

  # validate()

  test 'validate() restricts name changes' do
    @instance.name = 'cats'
    assert_raises ActiveRecord::RecordInvalid do
      @instance.save!
    end
  end

  test 'validate() restricts changes to the data type of system-required elements' do
    @instance.data_type = ElementDef::DataType::DATE
    assert_raises ActiveRecord::RecordInvalid do
      @instance.save!
    end
  end

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
