class AddLastSyncedToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :last_synced, :datetime

  end
end
