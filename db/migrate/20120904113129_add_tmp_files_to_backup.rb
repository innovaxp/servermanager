class AddTmpFilesToBackup < ActiveRecord::Migration
  def up
    add_column :backups, :tmp_files, :text
    remove_column :backups, :tmp_file
  end

  def down
    remove_column :backups, :tmp_files
    add_column :backups, :tmp_file, :string
  end

end
