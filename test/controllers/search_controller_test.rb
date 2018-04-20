require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest

  # index()

  test 'index() renders the index page' do
    get '/search'
    assert_response :ok
  end

end
