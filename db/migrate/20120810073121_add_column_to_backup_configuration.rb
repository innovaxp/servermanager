class AddColumnToBackupConfiguration < ActiveRecord::Migration
  def change
    add_column :backup_configurations, :name, :string

    add_column :backup_configurations, :all_dbs, :boolean

  end
end
