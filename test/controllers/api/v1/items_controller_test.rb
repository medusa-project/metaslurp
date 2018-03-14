require 'test_helper'
require File.expand_path('../api_controller_test.rb', __FILE__)

module Api

  class ItemsControllerTest < ApiControllerTest

    setup do
      @valid_item = Item.new(index_id: 'cats',
                             source_uri: 'http://example.org/cats')
      @valid_item.elements << ItemElement.new(name: 'name', value: 'value')
    end

    # update()

    test 'update() with no credentials returns 401' do
      put '/api/v1/items/' + @valid_item.index_id
      assert_response :unauthorized
    end

    test 'update() with invalid credentials returns 401' do
      headers = valid_headers.merge(
          'Authorization' => ActionController::HttpAuthentication::Basic.
              encode_credentials('bogus', 'bogus'))
      put '/api/v1/items/' + @valid_item.index_id, headers: headers
      assert_response :unauthorized
    end

    test 'update() with valid credentials and valid entity returns 200' do
      put '/api/v1/items/' + @valid_item.index_id,
          env: { 'rack.input': JSON.generate(@valid_item.as_json) },
          headers: valid_headers
      assert_response :success
    end

    test 'update() with valid credentials and empty entity returns 400' do
      put '/api/v1/items/' + @valid_item.index_id, headers: valid_headers
      assert_response :bad_request
    end

    test 'update() with valid credentials and malformed entity returns 400' do
      put '/api/v1/items/' + @valid_item.index_id,
          env: { 'rack.input': StringIO.new('malformed') },
          headers: valid_headers
      assert_response :bad_request
    end

  end

end