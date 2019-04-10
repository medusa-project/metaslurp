require 'test_helper'
require File.expand_path('../api_controller_test.rb', __FILE__)

module Api

  class ItemsControllerTest < ApiControllerTest

    setup do
      @valid_item = Item.new(id: 'cats',
                             full_text: 'Lorem ipsum',
                             variant: Item::Variants::ITEM,
                             media_type: 'image/jpeg',
                             parent_id: 'felines',
                             service_key: content_services(:one).key,
                             source_id: 'source-id',
                             source_uri: 'http://example.net/cats')
      @valid_item.elements << SourceElement.new(name: 'name1', value: 'value1')
      @valid_item.elements << SourceElement.new(name: 'name2', value: 'value2')
      @valid_item.images << Image.new(crop: :full,
                                      size: :full,
                                      uri: 'http://example.net/image.tif',
                                      master: true)

      @valid_json = @valid_item.as_json
      @valid_json['harvest_key'] = harvests(:new).key
    end

    # update()

    test 'update() with no credentials returns 401' do
      put '/api/v1/items/' + @valid_item.id
      assert_response :unauthorized
    end

    test 'update() with invalid credentials returns 401' do
      headers = valid_headers.merge(
          'Authorization' => ActionController::HttpAuthentication::Basic.
              encode_credentials('bogus', 'bogus'))
      put '/api/v1/items/' + @valid_item.id, headers: headers
      assert_response :unauthorized
    end

    test 'update() with valid credentials and valid entity returns 200' do
      put '/api/v1/items/' + @valid_item.id,
          env: { 'rack.input': JSON.generate(@valid_json) },
          headers: valid_headers
      assert_response :success
    end

    test 'update() with valid credentials and valid entity updates content
    service element mappings' do
      assert_nil @valid_item.content_service.element_mappings.
          find_by_source_name('name1')
      assert_nil @valid_item.content_service.element_mappings.
          find_by_source_name('name2')

      put '/api/v1/items/' + @valid_item.id,
          env: { 'rack.input': JSON.generate(@valid_json) },
          headers: valid_headers

      assert_not_nil @valid_item.content_service.element_mappings.
          find_by_source_name('name1')
      assert_not_nil @valid_item.content_service.element_mappings.
          find_by_source_name('name2')
    end

    test 'update() with valid credentials and empty entity returns 400' do
      put '/api/v1/items/' + @valid_item.id, headers: valid_headers
      assert_response :bad_request
    end

    test 'update() with valid credentials and malformed entity returns 400' do
      put '/api/v1/items/' + @valid_item.id,
          env: { 'rack.input': StringIO.new('malformed') },
          headers: valid_headers
      assert_response :bad_request
    end

    test 'update() with valid credentials and missing harvest key returns 400' do
      @valid_json['harvest_key'] = nil

      put '/api/v1/items/' + @valid_item.id,
          env: { 'rack.input': JSON.generate(@valid_json) },
          headers: valid_headers
      assert_response :bad_request
    end

    test 'update() with valid credentials and invalid harvest key returns 400' do
      @valid_json['harvest_key'] = 'bogus'

      put '/api/v1/items/' + @valid_item.id,
          env: { 'rack.input': JSON.generate(@valid_json) },
          headers: valid_headers
      assert_response :bad_request
    end

    test 'update() with valid credentials and key of aborted harvest returns 481' do
      @valid_json['harvest_key'] = harvests(:aborted)

      put '/api/v1/items/' + @valid_item.id,
          env: { 'rack.input': JSON.generate(@valid_json) },
          headers: valid_headers
      assert_equal 481, response.response_code
    end

    test 'update() with valid credentials and key of succeeded harvest returns 480' do
      @valid_json['harvest_key'] = harvests(:succeeded)

      put '/api/v1/items/' + @valid_item.id,
          env: { 'rack.input': JSON.generate(@valid_json) },
          headers: valid_headers
      assert_equal 480, response.response_code
    end

    test 'update() with valid credentials and key of failed harvest returns 480' do
      @valid_json['harvest_key'] = harvests(:failed)

      put '/api/v1/items/' + @valid_item.id,
          env: { 'rack.input': JSON.generate(@valid_json) },
          headers: valid_headers
      assert_equal 480, response.response_code
    end

  end

end