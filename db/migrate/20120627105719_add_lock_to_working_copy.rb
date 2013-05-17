class AddLockToWorkingCopy < ActiveRecord::Migration
  def change
    add_column :working_copies, :lock, :boolean

  end
end
