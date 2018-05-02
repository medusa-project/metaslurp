class ChangeFkTypesToBigint < ActiveRecord::Migration[5.1]
  def change
    change_column :element_mappings, :content_service_id, :bigint
    change_column :element_mappings, :element_def_id, :bigint
  end
end
