class AddFolderToBackupConfigurations < ActiveRecord::Migration
  def change
    add_column :backup_configurations, :folder, :string

  end
end
