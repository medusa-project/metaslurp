require 'test_helper'

class BoostTest < ActiveSupport::TestCase

  setup do
    @instance = boosts(:one)
  end

  # validate()

  test 'validate() requires boost to be in range' do
    @instance.boost = 11
    assert !@instance.valid?

    @instance.boost = -11
    assert !@instance.valid?

    @instance.boost = 0
    assert !@instance.valid?

    @instance.boost = 10
    assert @instance.valid?

    @instance.boost = -10
    assert @instance.valid?
  end

end
