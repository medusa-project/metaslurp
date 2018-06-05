class AddDataTypeColumnToElementDefs < ActiveRecord::Migration[5.2]
  def up
    add_column :element_defs, :data_type, :integer
    execute 'UPDATE element_defs SET data_type = 0'
    change_column :element_defs, :data_type, :integer, null: false
  end

  def down
    remove_column :element_defs, :data_type
  end
end
