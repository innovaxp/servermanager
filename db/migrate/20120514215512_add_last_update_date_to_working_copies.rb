class AddLastUpdateDateToWorkingCopies < ActiveRecord::Migration
  def change
    add_column :working_copies, :last_update_date, :datetime

  end
end
