class CreateContentServices < ActiveRecord::Migration[5.1]
  def change
    create_table :content_services do |t|
      t.string :name, null: false
      t.string :key, null: false
      t.string :uri
      t.string :description

      t.timestamps
    end

    add_index :content_services, :name, unique: true
    add_index :content_services, :key, unique: true
  end
end
