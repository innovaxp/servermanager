class CreateUploadServices < ActiveRecord::Migration
  def change
    create_table :upload_services do |t|
      t.string :name
      t.string :location
      t.text :meta

      t.timestamps
    end
  end
end
