require 'test_helper'

class ElementDefsControllerTest < ActionDispatch::IntegrationTest

  setup do
    setup_opensearch
    sign_in_as(users(:admin))
  end

  # create()

  test 'create() returns HTTP 200' do
    post '/admin/elements', params: {
      element_def: {
        name:      'new',
        label:     "New Element",
        data_type: ElementDef::DataType::STRING
      }
    }, xhr: true
    assert_response :ok
  end

  test 'create() creates an ElementDef' do
    post '/admin/elements', params: {
      element_def: {
        name:      'new',
        label:     "New Element",
        data_type: ElementDef::DataType::STRING
      }
    }, xhr: true
    assert_not_nil ElementDef.find_by_name('new')
  end

  # destroy()

  test 'destroy() destroys an ElementDef' do
    element = element_defs(:subject)
    delete admin_element_def_path(element)
    assert_raises ActiveRecord::RecordNotFound do
      element.reload
    end
  end

  test 'destroy() redirects after destroying' do
    element = element_defs(:subject)
    delete admin_element_def_path(element)
    assert_redirected_to admin_element_defs_path
  end

  # edit()

  test 'edit() renders the edit page' do
    element = element_defs(:subject)
    get edit_admin_element_def_path(element)
    assert_response :ok
  end

  # import()

  # TODO: test this

  # index()

  test 'index() renders the index page' do
    get admin_element_defs_path
    assert_response :ok
  end

  # show()

  test 'show() renders the show-ElementDef page' do
    element = element_defs(:subject)
    get admin_element_def_path(element)
    assert_response :ok
  end

  # update()

  test 'update() updates an ElementDef' do
    element = element_defs(:subject)

    patch admin_element_def_path(element), params: {
      element_def: {
        label: "New Label"
      }
    }
    element.reload
    assert_equal 'New Label', element.label
  end

end

