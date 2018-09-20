require 'test_helper'

class StringUtilsTest < ActiveSupport::TestCase

  # strip_leading_articles()

  test 'strip_leading_articles works' do
    expected = 'cat'
    # English
    assert_equal expected, StringUtils.strip_leading_articles('a cat')
    assert_equal expected, StringUtils.strip_leading_articles('A cat')
    assert_equal expected, StringUtils.strip_leading_articles('an cat')
    assert_equal expected, StringUtils.strip_leading_articles('An cat')
    assert_equal expected, StringUtils.strip_leading_articles('d\'cat')
    assert_equal expected, StringUtils.strip_leading_articles('D\'cat')
    assert_equal expected, StringUtils.strip_leading_articles('d’cat')
    assert_equal expected, StringUtils.strip_leading_articles('D’cat')
    assert_equal expected, StringUtils.strip_leading_articles('de cat')
    assert_equal expected, StringUtils.strip_leading_articles('De cat')
    assert_equal expected, StringUtils.strip_leading_articles('the cat')
    assert_equal expected, StringUtils.strip_leading_articles('The cat')
    assert_equal expected, StringUtils.strip_leading_articles('ye cat')
    assert_equal expected, StringUtils.strip_leading_articles('Ye cat')

    # French
    assert_equal expected, StringUtils.strip_leading_articles('l\'cat')
    assert_equal expected, StringUtils.strip_leading_articles('L\'cat')
    assert_equal expected, StringUtils.strip_leading_articles('l’cat')
    assert_equal expected, StringUtils.strip_leading_articles('L’cat')
    assert_equal expected, StringUtils.strip_leading_articles('la cat')
    assert_equal expected, StringUtils.strip_leading_articles('La cat')
    assert_equal expected, StringUtils.strip_leading_articles('le cat')
    assert_equal expected, StringUtils.strip_leading_articles('Le cat')
    assert_equal expected, StringUtils.strip_leading_articles('les cat')
    assert_equal expected, StringUtils.strip_leading_articles('Les cat')
  end

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
