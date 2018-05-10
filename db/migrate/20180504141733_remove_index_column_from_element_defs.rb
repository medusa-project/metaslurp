class RemoveIndexColumnFromElementDefs < ActiveRecord::Migration[5.2]
  def change
    remove_column :element_defs, :index
  end
end
