class AddLastRevisionToWorkingCopies < ActiveRecord::Migration
  def change
    add_column :working_copies, :last_revision, :integer

  end
end
