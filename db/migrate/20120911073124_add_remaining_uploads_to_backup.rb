class AddRemainingUploadsToBackup < ActiveRecord::Migration
  def change
    add_column :backups, :remaining_uploads, :integer

  end
end
