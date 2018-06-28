class AddUserIdColumnToHarvests < ActiveRecord::Migration[5.2]
  def change
    add_column :harvests, :user_id, :bigint
    add_foreign_key :harvests, :users,
                    on_update: :cascade, on_delete: :nullify
  end
end
