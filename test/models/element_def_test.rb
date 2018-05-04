require 'test_helper'

class ElementDefTest < ActiveSupport::TestCase

  setup do
    @element = element_defs(:title)
    assert @element.validate
  end

  # validate()

  test 'validate() should require unique names' do
    ElementDef.all.each_with_index do |e, i|
      e.name = 'title'
      if i == 0
        e.save!
      else
        assert_raises ActiveRecord::RecordInvalid do
          e.save!
        end
      end
    end
  end

end
