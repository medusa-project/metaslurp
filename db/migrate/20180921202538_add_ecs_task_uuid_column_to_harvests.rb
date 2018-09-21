class AddEcsTaskUuidColumnToHarvests < ActiveRecord::Migration[5.2]
  def change
    add_column :harvests, :ecs_task_uuid, :string
  end
end
