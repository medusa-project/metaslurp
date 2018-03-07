class CreateRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.string :key
      t.string :name

      t.timestamps
    end
    add_index :roles, :key

    create_join_table :roles, :users

    add_foreign_key :roles_users, :roles, on_update: :cascade, on_delete: :cascade
    add_foreign_key :roles_users, :users, on_update: :cascade, on_delete: :cascade
  end
end
