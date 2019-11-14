class AddMaxNumItemsColumnToHarvests < ActiveRecord::Migration[6.0]
  def change
    add_column :harvests, :max_num_items, :integer
  end
end
