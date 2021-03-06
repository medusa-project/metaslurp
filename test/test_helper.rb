require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def refresh_elasticsearch
    ElasticsearchClient.instance.refresh
  end

  def setup_elasticsearch
    index  = Configuration.instance.elasticsearch_index
    client = ElasticsearchClient.instance
    client.delete_index(index) if client.index_exists?(index)
    client.create_index(index)
  end

  def sign_in_as(user)
    post '/auth/developer/callback', params: {
        name: user.username, email: "#{user.username}@example.org"
    }
  end

  def sign_out
    delete signout_path
  end
end
