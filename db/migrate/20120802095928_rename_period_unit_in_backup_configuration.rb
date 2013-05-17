class RenamePeriodUnitInBackupConfiguration < ActiveRecord::Migration
  def up
    rename_column :backup_configurations, :period_unit, :period_number
    add_column :backup_configurations, :period_unit, :string
  end

  def down
    remove_column :backup_configurations, :period_unit
    rename_column :backup_configurations, :period_number, :period_unit
  end
end
