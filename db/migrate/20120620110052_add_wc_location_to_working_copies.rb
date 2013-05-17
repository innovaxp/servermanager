class AddWcLocationToWorkingCopies < ActiveRecord::Migration
  def change
    add_column :working_copies, :wc_location, :string

  end
end
