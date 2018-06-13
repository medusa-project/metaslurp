class AddUniqueIndexOnElementDefsName < ActiveRecord::Migration[5.2]
  def change
    remove_index :element_defs, :name
    add_index :element_defs, :name, unique: true
  end
end
