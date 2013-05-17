class CreateActionAlerts < ActiveRecord::Migration
  def change
    create_table :action_alerts do |t|
      t.integer :owner_id
      t.integer :alert_id
      t.string :action
      t.text :additional_emails

      t.timestamps
    end
  end
end
