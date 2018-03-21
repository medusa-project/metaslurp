require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase

  def setup
    @config_struct = YAML.load(
        ERB.new(
            File.read(
                File.join(Rails.root, 'config', 'metaslurp.yml'))).result)[Rails.env]
    @config = Configuration.instance
  end

  # get()

  test 'get() with a bogus config key should return nil' do
    assert_nil @config.get(:bogus)
  end

  test 'get() with a valid config key should return the value' do
    assert_equal @config_struct[:elasticsearch_endpoint],
                 @config.get(:elasticsearch_endpoint)
  end

  # method_missing()

  test 'method_missing() with a bogus config key should return nil' do
    assert_nil @config.bogus
  end

  test 'method_missing() with a valid config key should return the value' do
    assert_equal @config_struct[:elasticsearch_endpoint],
                 @config.elasticsearch_endpoint
  end

end
