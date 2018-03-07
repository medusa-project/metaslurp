class CreateElements < ActiveRecord::Migration[5.1]
  def change
    create_table :elements do |t|
      t.string :name
      t.string :label
      t.string :description
      t.integer :index
      t.boolean :searchable, default: true
      t.boolean :sortable, default: true
      t.boolean :facetable, default: true

      t.timestamps
    end
    add_index :elements, :name
    add_index :elements, :index
    add_index :elements, :searchable
    add_index :elements, :sortable
    add_index :elements, :facetable
  end
end
