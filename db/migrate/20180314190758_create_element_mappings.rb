class CreateElementMappings < ActiveRecord::Migration[5.1]
  def change
    create_table :element_mappings do |t|
      t.integer :content_service_id
      t.string :source_name
      t.integer :element_id

      t.timestamps
    end
    add_index :element_mappings, [:content_service_id, :source_name],
              unique: true
    add_foreign_key :element_mappings, :content_services,
                    on_update: :cascade, on_delete: :cascade
    add_foreign_key :element_mappings, :elements,
                    on_update: :cascade, on_delete: :cascade
  end
end
