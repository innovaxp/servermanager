class AddMetaToRemoteServer < ActiveRecord::Migration
  def change
    add_column :remote_servers, :meta, :text

  end
end
