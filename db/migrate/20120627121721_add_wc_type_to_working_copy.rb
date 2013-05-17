class AddWcTypeToWorkingCopy < ActiveRecord::Migration
  def change
    add_column :working_copies, :wc_type, :string

  end
end
