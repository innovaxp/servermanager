class AddHostToRemoteServers < ActiveRecord::Migration
  def change
    add_column :remote_servers, :host, :string

  end
end
