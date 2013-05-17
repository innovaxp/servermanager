class AddOwnerIdToBackupConfiguration < ActiveRecord::Migration
  def change
    add_column :backup_configurations, :owner_id, :integer

  end
end
