require 'test_helper'

class ImageTest < ActiveSupport::TestCase

  setup do
    @instance = Image.new(crop: 'full',
                          size: 'full',
                          master: true,
                          uri: 'http://example.org/image.jpg')
  end

  test 'as_json works with numeric size' do
    @instance = Image.new(crop: 'full',
                          size: 256,
                          master: false,
                          uri: 'http://example.org/image.jpg')

    expected = {
        'crop'   => 'full',
        'size'   => 256,
        'master' => false,
        'uri'    => 'http://example.org/image.jpg'
    }
    assert_equal expected, @instance.as_json
  end

  test 'as_json works with full size' do
    expected = {
        'crop'   => 'full',
        'size'   => 0,
        'master' => true,
        'uri'    => 'http://example.org/image.jpg'
    }
    assert_equal expected, @instance.as_json
  end

end
