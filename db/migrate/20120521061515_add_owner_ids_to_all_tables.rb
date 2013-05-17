class AddOwnerIdsToAllTables < ActiveRecord::Migration
  def change
    add_column :remote_servers, :owner_id, :integer
	add_column :repositories, :owner_id, :integer
	add_column :working_copies, :owner_id, :integer
	add_column :users, :owner_id, :integer
  end
end
