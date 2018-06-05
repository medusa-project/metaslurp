require 'test_helper'

class TimeUtilsTest < ActiveSupport::TestCase

  # string_date_to_time()

  test 'string_date_to_time() with a nil argument returns nil' do
    assert_nil TimeUtils.string_date_to_time(nil)
  end

  test 'string_date_to_time() with an unrecognizable argument raises an ArgumentError' do
    assert_raises ArgumentError do
      TimeUtils.string_date_to_time('cats')
    end
  end

  test 'string_date_to_time() works with AA' do
    assert_equal Time.parse('1923-02-12 03:52:46Z'),
                 TimeUtils.string_date_to_time('1923-02-12T03:52:46')
    assert_equal Time.parse('1923-02-12 03:52:46Z'),
                 TimeUtils.string_date_to_time('1923-02-12T03:52:46Z')
  end

  test 'string_date_to_time() works with AB' do
    assert_equal Time.parse('1923-02-12 12:10:50Z'),
                 TimeUtils.string_date_to_time('1923:02:12 12:10:50')
  end

  test 'string_date_to_time() works with AC' do
    assert_equal Time.parse('1923-02-12 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923:02:12')
  end

  test 'string_date_to_time() works with AD' do
    assert_equal Time.parse('1923-02-12 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923-02-12')
  end

  test 'string_date_to_time() works with AE' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923')
  end

  test 'string_date_to_time() works with AF' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('[1923]')
  end

  test 'string_date_to_time() works with AG' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('[[1923]')
  end

  test 'string_date_to_time() works with AH' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923]')
  end

  test 'string_date_to_time() works with AI' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('[1923?]')
  end

  test 'string_date_to_time() works with AJ' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923?]')
  end

  test 'string_date_to_time() works with AK' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923, c1925')
  end

  test 'string_date_to_time() works with AL' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('c1923')
  end

  test 'string_date_to_time() works with AM' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('[c1923]')
  end

  test 'string_date_to_time() works with AN' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('©1923')
  end

  test 'string_date_to_time() works with AO' do
    assert_equal Time.parse('1923-10-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('October 1923')
  end

  test 'string_date_to_time() works with AP' do
    assert_equal Time.parse('1923-10-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('October, 1923')
  end

  test 'string_date_to_time() works with AQ' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('[1923 or 1924]')
  end

  test 'string_date_to_time() works with NA' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923-')
  end

  test 'string_date_to_time() works with NB' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923-1925')
  end

  test 'string_date_to_time() works with NC' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('1923-, c1925')
  end

  test 'string_date_to_time() works with ND' do
    assert_equal Time.parse('1920-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('192-]')
  end

  test 'string_date_to_time() works with NE' do
    assert_equal Time.parse('1925-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('[1925-27]')
  end

  test 'string_date_to_time() works with NF' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('[between 1923 and 1925]')
  end

  test 'string_date_to_time() works with NG' do
    assert_equal Time.parse('1923-01-01 00:00:00Z'),
                 TimeUtils.string_date_to_time('[1923]-<1925 >')
  end

end
