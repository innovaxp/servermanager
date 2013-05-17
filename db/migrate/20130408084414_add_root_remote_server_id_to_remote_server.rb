class AddRootRemoteServerIdToRemoteServer < ActiveRecord::Migration
  def change
    add_column :remote_servers, :root_remote_server_id, :integer

  end
end
