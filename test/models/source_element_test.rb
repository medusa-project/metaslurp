require 'test_helper'

class SourceElementTest < ActiveSupport::TestCase

  setup do
    @instance = SourceElement.new(name: 'name', value: 'value')
  end

  # from_json()

  test 'from_json() with valid data returns an instance' do
    name = 'name'
    value = 'value'
    e = SourceElement.from_json({ 'name': name, 'value': value })

    assert_equal name, e.name
    assert_equal value, e.value
  end

  test 'from_json() with invalid data raises an error' do
    assert_raises ArgumentError do
      SourceElement.from_json({ 'cats': 'cats', 'dogs': 'dogs' })
    end
  end

  # initialize()

  test 'initialize() works' do
    e = SourceElement.new(name: 'name', value: 'value')
    assert_equal 'name', e.name
    assert_equal 'value', e.value
  end

  # ==()

  test '==() with equal instance' do
    e = SourceElement.new(name: 'name', value: 'value')
    assert_equal e, @instance
  end

  test '==() with different name' do
    e = SourceElement.new(name: 'name2', value: 'value')
    assert_not_equal e, @instance
  end

  test '==() with different value' do
    e = SourceElement.new(name: 'name', value: 'value2')
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

  test 'validate() raises error for invalid name' do
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
