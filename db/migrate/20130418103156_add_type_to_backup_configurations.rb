class AddTypeToBackupConfigurations < ActiveRecord::Migration
  def change
    add_column :backup_configurations, :type, :string

  end
end
