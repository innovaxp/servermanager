class AddTmpFileToBackup < ActiveRecord::Migration
  def change
    add_column :backups, :tmp_file, :string

  end
end
