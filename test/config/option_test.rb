require 'test_helper'

class OptionTest < ActiveSupport::TestCase

  # boolean()

  test 'boolean() returns a boolean for an existing key' do
    key = 'bla'
    Option.create!(key: key, value: true)
    assert Option.boolean(key)
  end

  test 'boolean() returns nil for a nonexistent key with no default argument' do
    assert_nil Option.boolean('bogus')
  end

  test 'boolean() returns the default argument for a nonexistent key' do
    assert Option.boolean('bogus', true)
  end

  # integer()

  test 'integer() returns an integer for an existing key' do
    key = 'bla'
    Option.create!(key: key, value: 123)
    assert_equal 123, Option.integer(key)
  end

  test 'integer() returns nil for a nonexistent key with no default argument' do
    assert_nil Option.integer('bogus')
  end

  test 'integer() returns the default argument for a nonexistent key' do
    assert_equal 52, Option.integer('bogus', 52)
  end

  # set()

  test 'set() updates the value of an existing key' do
    key = 'cats'
    Option.set(key, 'test')
    assert_equal 'test', Option.string(key)
    Option.set(key, 'test2')
    assert_equal 'test2', Option.string(key)
  end

  test 'set() creates a new Option for a new key' do
    key = 'cats'
    assert_nil Option.find_by_key(key)
    Option.set(key, 'test')
    assert_not_nil Option.find_by_key(key)
  end

  # string()

  test 'string() returns a string for an existing key' do
    key = 'bla'
    Option.create!(key: key, value: 'cats')
    assert_equal 'cats', Option.string(key)
  end

  test 'string() returns nil for a nonexistent key with no default argument' do
    assert_nil Option.string('bogus')
  end

  test 'string() returns the default argument for a nonexistent key' do
    assert_equal 'default', Option.string('bogus', 'default')
  end

end
