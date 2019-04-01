class AddWeightColumnToElementDefs < ActiveRecord::Migration[5.2]
  def change
    add_column :element_defs, :weight, :integer, default: 0, null: false
    add_index :element_defs, :weight
  end
end
