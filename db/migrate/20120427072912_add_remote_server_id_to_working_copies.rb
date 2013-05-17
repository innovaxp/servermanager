class AddRemoteServerIdToWorkingCopies < ActiveRecord::Migration
  def change
    add_column :working_copies, :remote_server_id, :integer

  end
end
