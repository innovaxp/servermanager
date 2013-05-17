class AddTypeToWorkingCopies < ActiveRecord::Migration
  def change
    add_column :working_copies, :type, :string

  end
end
