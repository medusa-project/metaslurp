require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in_as(users(:admin))
  end

  # create()

  test 'create() creates a user' do
    post '/admin/users', params: {
      user: {
        username: 'cats'
      }
    }
    assert_not_nil User.find_by_username('cats')
  end

  test 'create() redirects to the created user' do
    post '/admin/users', params: {
      user: {
        username: 'cats'
      }
    }
    assert_redirected_to admin_user_path(User.find_by_username('cats'))
  end

  # destroy()

  test 'destroy() destroys the user' do
    user = users(:admin)
    delete "/admin/users/#{user.username}"
    assert_nil User.find_by_username(user.username)
  end

  test 'destroy() redirects after destroying' do
    user = users(:admin)
    delete "/admin/users/#{user.username}"
    assert_redirected_to admin_users_path
  end

  # edit()

  test 'edit() renders the edit page' do
    user = users(:admin)
    get "/admin/users/#{user.username}"
    assert_response :ok
  end

  # index()

  test 'index() renders the index page' do
    get '/admin/users'
    assert_response :ok
  end

  # new()

  test 'new() renders the new-user page' do
    get '/admin/users/new'
    assert_response :ok
  end

  # show()

  test 'show() renders the show-user page' do
    user = users(:admin)
    get "/admin/users/#{user.username}"
    assert_response :ok
  end

  # update()

  test 'update() updates a user' do
    user = users(:admin)

    patch "/admin/users/#{user.username}", params: {
      user: {
        username: 'cats'
      }
    }

    user.reload
    assert_equal 'cats', user.username
  end

end

