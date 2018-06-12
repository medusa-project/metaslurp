class CreateHarvests < ActiveRecord::Migration[5.2]
  def change
    create_table :harvests do |t|
      t.bigint :content_service_id, null: false
      t.string :key, null: false
      t.integer :status, default: 0, null: false
      t.integer :num_items, default: 0, null: false
      t.integer :num_succeeded, default: 0, null: false
      t.integer :num_failed, default: 0, null: false
      t.datetime :ended_at
      t.text :message

      t.timestamps
    end

    add_foreign_key :harvests, :content_services,
                    on_update: :cascade, on_delete: :cascade
    add_index :harvests, :key, unique: true
    add_index :harvests, :status
  end
end
