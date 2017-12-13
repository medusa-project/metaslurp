require 'test_helper'

class ContentServicesControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in_as(users(:admin))
  end

  def valid_params
    {
        params: {
            content_service: {
                name: 'Cats Cats Cats',
                key: 'cats',
                description: 'Cats'
            }
        }
    }
  end

  # create()

  test 'create() creates a service' do
    post '/admin/content-services', valid_params
    assert_not_nil ContentService.find_by_key('cats')
  end

  test 'create() redirects to the created model' do
    post '/admin/content-services', valid_params
    assert_redirected_to admin_content_service_path(ContentService.find_by_key('cats'))
  end

  # destroy()

  test 'destroy() destroys the model' do
    service = content_services(:one)
    delete "/admin/content-services/#{service.key}"
    assert_nil ContentService.find_by_key(service.key)
  end

  test 'destroy() redirects after destroying' do
    service = content_services(:one)
    delete "/admin/content-services/#{service.key}"
    assert_redirected_to admin_content_services_path
  end

  # edit()

  test 'edit() renders the edit page' do
    service = content_services(:one)
    get "/admin/content-services/#{service.key}"
    assert_response :ok
  end

  # index()

  test 'index() renders the index page' do
    get '/admin/content-services'
    assert_response :ok
  end

  # new()

  test 'new() renders the new-content-service page' do
    get '/admin/content-services/new'
    assert_response :ok
  end

  # show()

  test 'show() renders the show-content-service page' do
    service = content_services(:one)
    get "/admin/content-services/#{service.key}"
    assert_response :ok
  end

  # update()

  test 'update() updates a service' do
    service = content_services(:one)

    patch "/admin/content-services/#{service.key}", valid_params

    service.reload
    assert_equal 'cats', service.key
  end

end

