class AddTypeToRemoteServer < ActiveRecord::Migration
  def change
    add_column :remote_servers, :type, :string

  end
end
