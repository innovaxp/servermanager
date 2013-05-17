class CreateUserPermissions < ActiveRecord::Migration
  def change
    create_table :user_permissions do |t|
      t.integer :user_id
      t.integer :repository_id
      t.boolean :read_permission
      t.boolean :write_permission

      t.timestamps
    end
  end
end
