class AddLastSyncDateToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :last_sync_date, :datetime

  end
end
