require 'test_helper'

class ElementTest < ActiveSupport::TestCase

  setup do
    @instance = Element.new(name: 'name', value: 'value')
  end

  # initialize()

  test 'initialize() works' do
    e = Element.new(name: 'name', value: 'value')
    assert_equal 'name', e.name
    assert_equal 'value', e.value
  end

  # ==()

  test '==() with equal instance' do
    e = Element.new(name: 'name', value: 'value')
    assert_equal e, @instance
  end

  test '==() with different name' do
    e = Element.new(name: 'name2', value: 'value')
    assert_not_equal e, @instance
  end

  test '==() with different value' do
    e = Element.new(name: 'name', value: 'value2')
    assert_not_equal e, @instance
  end

  # as_json()

  test 'as_json() works' do
    struct = { 'name': 'name', 'value': 'value' }.stringify_keys
    assert_equal struct, @instance.as_json
  end

  # validate()

  test 'validate() returns for valid instance' do
    @instance.validate
  end

  test 'validate() raises error for missing name' do
    @instance.name = ''
    assert_raises ArgumentError do
      @instance.validate
    end
  end

  test 'validate() raises error for invalid value' do
    @instance.value = ''
    assert_raises ArgumentError do
      @instance.validate
    end
  end

end
