require 'test_helper'
require File.expand_path('../api_controller_test.rb', __FILE__)

module Api

  class ElementsControllerTest < ApiControllerTest

    # index()

    test 'index() with no credentials should return 401' do
      get('/api/v1/elements')
      assert_response :unauthorized
    end

    test 'index() with invalid credentials should return 401' do
      headers = valid_headers.merge(
          'Authorization' => ActionController::HttpAuthentication::Basic.
              encode_credentials('bogus', 'bogus'))
      get '/api/v1/elements', headers: headers
      assert_response :unauthorized
    end

    test 'index() with valid credentials should return 200' do
      get '/api/v1/elements', headers: valid_headers
      assert_response :success
    end

  end

end