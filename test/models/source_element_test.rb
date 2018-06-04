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

end
