class AddFacetOrderColumnToElementDefs < ActiveRecord::Migration[7.1]
  def change
    add_column :element_defs, :facet_order, :integer, default: 0, null: false
  end
end
