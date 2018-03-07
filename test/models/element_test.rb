require 'test_helper'

class ElementTest < ActiveSupport::TestCase

  setup do
    @element = elements(:title)
    assert @element.validate
  end

  # create()

  test 'create() should update other element indexes' do
    Element.create!(name: 'new', label: 'New', index: 1)
    # Assert that the indexes are sequential and zero-based.
    Element.all.order(:index).each_with_index do |e, i|
      assert_equal i, e.index
    end
  end

  # destroy()

  test 'destroy() should update indexes of other elements' do
    @element.destroy!
    # Assert that the indexes are sequential and zero-based.
    Element.all.order(:index).each_with_index do |e, i|
      assert_equal i, e.index
    end
  end

  # update()

  test 'update() should update indexes of other elements when increasing an
  element index' do
    assert_equal 0, @element.index
    @element.update!(index: 2)
    # Assert that the indexes are sequential and zero-based.
    Element.all.order(:index).each_with_index do |e, i|
      assert_equal i, e.index
    end
  end

  test 'update() should update other element indexes when decreasing an
  element index' do
    @element = Element.where(index: 2).first
    @element.update!(index: 0)
    # Assert that the indexes are sequential and zero-based.
    Element.all.order(:index).each_with_index do |e, i|
      assert_equal i, e.index
    end
  end

  # validate()

  test 'validate() should require unique names' do
    Element.all.order(:index).each_with_index do |e, i|
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

  test 'validate() should disallow negative indexes' do
    @element.index = -1
    assert !@element.validate
  end

end
