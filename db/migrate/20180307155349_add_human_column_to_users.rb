class AddHumanColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :human, :boolean, default: true
  end
end
