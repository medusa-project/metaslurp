class CreateOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :configuration do |t|
      t.string :key
      t.string :value

      t.timestamps
    end

    add_index :configuration, :key
  end
end
