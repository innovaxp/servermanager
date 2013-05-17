class RemoveAllDbsFromBackupConfigurations < ActiveRecord::Migration
  def change
    remove_column :backup_configurations, :all_dbs

  end
  
end
