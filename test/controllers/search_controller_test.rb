require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest

  setup do
    setup_elasticsearch
  end

  # index()

  test 'index() renders the index page' do
    get '/search'
    assert_response :ok
  end

end
