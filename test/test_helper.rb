require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def refresh_opensearch
    OpenSearchClient.instance.refresh
  end

  def setup_opensearch
    index  = Configuration.instance.opensearch_index
    client = OpenSearchClient.instance
    client.delete_index(index) if client.index_exists?(index)
    client.create_index(index)
  end

  def sign_in_as(user)
    post '/auth/developer/callback', env: {
      'omniauth.auth': {
        uid: user.username
      }
    }
  end

  def sign_out
    delete signout_path
  end
end
