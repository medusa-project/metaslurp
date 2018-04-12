require 'test_helper'

class CollectionsControllerTest < ActionDispatch::IntegrationTest

  # index()

  test 'index() renders the index page' do
    get '/collections'
    assert_response :ok
  end

end
