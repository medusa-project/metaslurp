class CreateBoosts < ActiveRecord::Migration[5.2]
  def change
    create_table :boosts do |t|
      t.string :field, null: false
      t.string :value, null: false
      t.integer :boost, null: false

      t.timestamps
    end
    add_index :boosts, [:field, :value], unique: true
  end
end
