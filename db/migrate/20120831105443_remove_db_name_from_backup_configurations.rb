class RemoveDbNameFromBackupConfigurations < ActiveRecord::Migration
  def change
    remove_column :backup_configurations, :db_name

  end
  
end
