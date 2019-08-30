class RemoveContentServiceDescriptions < ActiveRecord::Migration[5.2]
  def change
    remove_column :content_services, :description
  end
end
