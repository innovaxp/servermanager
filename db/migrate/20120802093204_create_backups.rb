class CreateBackups < ActiveRecord::Migration
  def change
    create_table :backups do |t|
      t.integer :backup_configuration_id
      t.string :status
      t.text :meta

      t.timestamps
    end
  end
end
