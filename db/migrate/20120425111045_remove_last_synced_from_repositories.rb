class RemoveLastSyncedFromRepositories < ActiveRecord::Migration
  def up
	  remove_column :repositories, :last_synced
  end

  def down
	  add_column :repositories, :last_synced, :datetime
  end
end
