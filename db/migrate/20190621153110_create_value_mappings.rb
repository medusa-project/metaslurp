class CreateValueMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :value_mappings do |t|
      t.string :source_value
      t.string :local_value
      t.bigint :element_def_id

      t.timestamps
    end
    add_index :value_mappings, [:element_def_id, :source_value],
              unique: true
    add_foreign_key :value_mappings, :element_defs,
                    on_update: :cascade, on_delete: :cascade
  end
end
