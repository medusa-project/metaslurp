class RenameElementsToElementDefs < ActiveRecord::Migration[5.2]
  def change
    rename_table :elements, :element_defs
    rename_column :element_mappings, :element_def_id, :element_def_id
  end
end
