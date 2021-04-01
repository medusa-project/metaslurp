require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase

  def setup
    @config = Configuration.instance
  end

  # get()

  test "get() with a bogus key returns nil" do
    assert_nil @config.get(:bogus)
  end

  test "get() with a string key returns the value" do
    assert_not_nil @config.get("db_host")
  end

  test "get() with a symbol key returns the value" do
    assert_not_nil @config.get(:db_host)
  end

  test "get() indifferent hash access" do
    assert_not_nil @config.get(:test)["key"]
    assert_not_nil @config.get(:test)[:key]
  end

  # method_missing()

  test "method_missing() with a bogus key returns nil" do
    assert_nil @config.bogus
  end

  test "method_missing() with a valid key returns the value" do
    assert_not_nil @config.db_host
  end

end
