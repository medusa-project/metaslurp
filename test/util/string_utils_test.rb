require 'test_helper'

class StringUtilsTest < ActiveSupport::TestCase

  # truncate()

  test 'truncate() truncates the string if necessary' do
    str = 'The quick brown fox jumped over the lazy dog'
    assert_equal 'The quick brown...', StringUtils.truncate(str, 15)
    assert_equal 'The quick brown...', StringUtils.truncate(str, 17)
    assert_equal 'The quick brown fox...', StringUtils.truncate(str, 19)
  end

  test 'truncate() returns the input string if truncation is not necessary' do
    str = 'The quick brown fox'
    assert_same str, StringUtils.truncate(str, 50)
  end

end
