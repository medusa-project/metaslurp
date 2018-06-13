class AddIndexOnHarvestsCreatedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :harvests, :created_at
  end
end
