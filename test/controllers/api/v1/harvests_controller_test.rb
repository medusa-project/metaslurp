require 'test_helper'
require File.expand_path('../api_controller_test.rb', __FILE__)

module Api

  class HarvestsControllerTest < ApiControllerTest

    setup do
      @valid_harvest = harvests(:new)
    end

    # create()

    test 'create() with no credentials returns 401' do
      post '/api/v1/harvests'
      assert_response :unauthorized
    end

    test 'create() with invalid credentials returns 401' do
      headers = valid_headers.merge(
          'Authorization' => ActionController::HttpAuthentication::Basic.
              encode_credentials('bogus', 'bogus'))
      post '/api/v1/harvests', headers: headers
      assert_response :unauthorized
    end

    test 'create() with valid credentials and valid entity returns 200' do
      post '/api/v1/harvests',
            env: { 'rack.input': "{ \"service_key\": \"#{content_services(:one).key}\" }" },
            headers: valid_headers
      assert_response :success

      json = JSON.parse(response.body)
      assert json['path'].match?(/^\/api\/v1\/harvests\/[a-z0-9]/)
      assert json['key'].match?(/^[a-z0-9]/)
    end

    test 'create() with valid credentials and empty entity returns 400' do
      post '/api/v1/harvests', headers: valid_headers
      assert_response :bad_request
    end

    test 'create() with valid credentials and malformed entity returns 400' do
      post '/api/v1/harvests',
            env: { 'rack.input': StringIO.new('malformed') },
            headers: valid_headers
      assert_response :bad_request
    end

    # update()

    test 'update() with no credentials returns 401' do
      patch '/api/v1/harvests/' + @valid_harvest.key
      assert_response :unauthorized
    end

    test 'update() with invalid credentials returns 401' do
      headers = valid_headers.merge(
          'Authorization' => ActionController::HttpAuthentication::Basic.
              encode_credentials('bogus', 'bogus'))
      patch '/api/v1/harvests/' + @valid_harvest.key, headers: headers
      assert_response :unauthorized
    end

    test 'update() with valid credentials and valid entity returns 200' do
      patch '/api/v1/harvests/' + @valid_harvest.key,
          env: { 'rack.input': JSON.generate(@valid_harvest.as_json) },
          headers: valid_headers
      assert_response :success
    end

    test 'update() with valid credentials and empty entity returns 400' do
      patch '/api/v1/harvests/' + @valid_harvest.key, headers: valid_headers
      assert_response :bad_request
    end

    test 'update() with valid credentials and malformed entity returns 400' do
      patch '/api/v1/harvests/' + @valid_harvest.key,
          env: { 'rack.input': StringIO.new('malformed') },
          headers: valid_headers
      assert_response :bad_request
    end

  end

end