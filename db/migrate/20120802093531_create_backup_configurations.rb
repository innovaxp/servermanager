class CreateBackupConfigurations < ActiveRecord::Migration
  def change
    create_table :backup_configurations do |t|
      t.integer :remote_server_id
      t.string :db_name
      t.string :db_user
      t.string :db_password
      t.string :local_folder
      t.string :local_folder_url
      t.integer :upload_service_id
      t.boolean :remove_local
      t.integer :period_unit
      t.string :period_unit
      t.text :notify_to

      t.timestamps
    end
  end
end
