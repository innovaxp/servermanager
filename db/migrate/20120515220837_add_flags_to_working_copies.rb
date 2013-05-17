class AddFlagsToWorkingCopies < ActiveRecord::Migration
  def change
    add_column :working_copies, :flags, :text

  end
end
