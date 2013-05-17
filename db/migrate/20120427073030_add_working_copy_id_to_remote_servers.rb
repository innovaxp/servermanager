class AddWorkingCopyIdToRemoteServers < ActiveRecord::Migration
  def change
    add_column :remote_servers, :working_copy_id, :integer

  end
end
