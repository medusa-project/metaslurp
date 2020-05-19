require 'test_helper'

class HarvestsControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in_as(users(:admin))
  end

  # abort()

  test 'abort() aborts the harvest' do
    harvest = harvests(:new)
    patch "/admin/harvests/#{harvest.key}/abort"
    assert_redirected_to admin_harvest_path(harvest)
    harvest.reload
    assert_equal Harvest::Status::ABORTED, harvest.status
  end

  # destroy()

  test 'destroy() destroys the given harvest' do
    harvest = harvests(:new)
    delete admin_harvest_path(harvest)
    assert_raises ActiveRecord::RecordNotFound do
      harvest.reload
    end
    assert_redirected_to admin_harvests_path
  end

  # index()

  test 'index() renders the index page' do
    get '/admin/harvests'
    assert_response :ok
  end

  # show()

  test 'show() renders the show page' do
    harvest = harvests(:new)
    get "/admin/harvests/#{harvest.key}"
    assert_response :ok
  end

end

