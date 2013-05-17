class AddDatabasesToBackupConfigurations < ActiveRecord::Migration
  def change
    add_column :backup_configurations, :databases, :text

  end
end
