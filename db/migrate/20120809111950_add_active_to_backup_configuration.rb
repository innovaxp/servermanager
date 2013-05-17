class AddActiveToBackupConfiguration < ActiveRecord::Migration
  def change
    add_column :backup_configurations, :active, :boolean

  end
end
