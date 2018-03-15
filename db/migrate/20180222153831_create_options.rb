class CreateOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :options do |t|
      t.string :key
      t.string :value

      t.timestamps
    end

    add_index :options, :key
  end
end
