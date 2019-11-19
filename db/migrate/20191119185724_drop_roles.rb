class DropRoles < ActiveRecord::Migration[6.0]
  def change
    drop_table :roles_users
    drop_table :roles
  end
end
