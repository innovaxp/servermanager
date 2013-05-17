class AddOwnerIdToUploadService < ActiveRecord::Migration
  def change
    add_column :upload_services, :owner_id, :integer

  end
end
