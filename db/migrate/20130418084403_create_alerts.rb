class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.integer :owner_id
      t.text :additional_emails

      t.timestamps
    end
  end
end
