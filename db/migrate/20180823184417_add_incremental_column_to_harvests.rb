class AddIncrementalColumnToHarvests < ActiveRecord::Migration[5.2]
  def change
    add_column :harvests, :incremental, :boolean, null: false, default: false
  end
end
