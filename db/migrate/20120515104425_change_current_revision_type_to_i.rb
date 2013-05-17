class ChangeCurrentRevisionTypeToI < ActiveRecord::Migration
  def up
	  change_column :working_copies, :current_revision, :integer
  end

  def down
	  change_column :working_copies, :current_revision, :string
  end
end
