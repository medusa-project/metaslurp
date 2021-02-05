require 'test_helper'

class CollectionsControllerTest < ActionDispatch::IntegrationTest

  setup do
    setup_elasticsearch
  end

  # index()

  test 'index() renders the index page' do
    get '/collections'
    assert_response :ok
  end

end
