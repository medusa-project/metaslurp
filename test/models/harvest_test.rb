require 'test_helper'

class HarvestTest < ActiveSupport::TestCase

  setup do
    @instance = harvests(:new)
  end

  # content_service()

  test 'content_service() returns the associated ContentService' do
    assert_equal content_services(:one), @instance.content_service
  end

  # destroy()

  test 'destroy() raises an error if the instance is not destroyable' do
    @instance = harvests(:running)
    assert_raises ActiveRecord::RecordNotDestroyed do
      @instance.destroy!
    end
  end

  # progress()

  test 'progress() returns 0 when the status is  Status::NEW' do
    @instance               = harvests(:new)
    @instance.num_items     = 100
    @instance.num_succeeded = 75
    @instance.num_failed    = 5
    assert_equal 0, @instance.progress
  end

  test 'progress() reports a correct figure for empty harvests' do
    @instance               = harvests(:running)
    @instance.num_items = 0
    assert_equal 1, @instance.progress
  end

  test 'progress() reports a correct figure for non-empty harvests' do
    @instance               = harvests(:running)
    @instance.num_items = 100
    assert_equal 0, @instance.progress

    @instance.num_succeeded = 20
    @instance.num_failed = 5
    assert_equal 0.25, @instance.progress
  end

  test 'progress() clamps the max return value to 1' do
    @instance               = harvests(:running)
    @instance.num_items     = 100
    @instance.num_succeeded = 125
    @instance.num_failed    = 5
    assert_equal 1, @instance.progress
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
    @instance.update_from_json(status: 2, num_items: 50,
                               messages: ['cats', 'dogs'])
    assert_equal 2, @instance.status
    assert_equal 50, @instance.num_items
    assert_equal "cats\ndogs", @instance.message
  end

  test 'update_from_json() respects validation' do
    @instance = harvests(:aborted)
    assert_raises ActiveRecord::RecordInvalid do
      @instance.update_from_json(status: Harvest::Status::RUNNING)
    end
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
    h2 = Harvest.create!(content_service: content_services(:one),
                         user: users(:admin))
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

  test 'validate() returns false if status is being changed from a terminal status' do
    @instance = harvests(:succeeded)
    @instance.status = Harvest::Status::RUNNING
    assert !@instance.validate

    @instance = harvests(:failed)
    @instance.status = Harvest::Status::RUNNING
    assert !@instance.validate

    @instance = harvests(:aborted)
    @instance.status = Harvest::Status::RUNNING
    assert !@instance.validate
  end

  test 'validate() returns true if status is being changed legally' do
    @instance.status = Harvest::Status::RUNNING
    assert @instance.validate

    @instance = harvests(:new)
    @instance.status = Harvest::Status::SUCCEEDED
    assert @instance.validate

    @instance = harvests(:new)
    @instance.status = Harvest::Status::FAILED
    assert @instance.validate

    @instance = harvests(:new)
    @instance.status = Harvest::Status::ABORTED
    assert @instance.validate

    @instance = harvests(:new)
    @instance.status = Harvest::Status::SUCCEEDED
    assert @instance.validate

    @instance = harvests(:running)
    @instance.status = Harvest::Status::FAILED
    assert @instance.validate

    @instance = harvests(:running)
    @instance.status = Harvest::Status::ABORTED
    assert @instance.validate
  end

end
