require 'test_helper'

class HarvestTest < ActiveSupport::TestCase

  setup do
    @instance = harvests(:new)
  end

  # content_service()

  test 'content_service() returns the associated ContentService' do
    assert_equal content_services(:one), @instance.content_service
  end

  # progress()

  test 'progress() reports a correct figure' do
    assert_equal 0, @instance.progress

    @instance.num_items = 100
    assert_equal 0, @instance.progress

    @instance.num_succeeded = 20
    @instance.num_failed = 5
    assert_equal 0.25, @instance.progress
  end

  # update()

  test 'update() restricts key changes' do
    assert_raises ActiveRecord::RecordInvalid do
      @instance.update!(key: 'new5')
    end
  end

  # update_from_json()

  test 'update_from_json() raises an error when given an illegal argument' do
    assert_raises ArgumentError do
      @instance.update_from_json('')
    end
  end

  test 'update_from_json() works' do
    @instance.update_from_json(status: 2, num_items: 50)
    assert_equal 2, @instance.status
    assert_equal 50, @instance.num_items
  end

  # validate()

  test 'validate() returns for valid instance' do
    @instance.validate
  end

  test 'validate() returns false if content_service_id is blank' do
    @instance.content_service_id = ''
    assert !@instance.validate
  end

  test 'validate() returns false if key is blank' do
    @instance.key = ''
    assert !@instance.validate
  end

  test 'validate() returns false if key is not unique' do
    h2 = Harvest.create!(content_service: content_services(:one))
    @instance.key = h2.key
    assert !@instance.validate
  end

  test 'validate() returns false if status is blank' do
    @instance.status = ''
    assert !@instance.validate
  end

  test 'validate() returns false if status is invalid' do
    @instance.status = 502
    assert !@instance.validate
  end

end
