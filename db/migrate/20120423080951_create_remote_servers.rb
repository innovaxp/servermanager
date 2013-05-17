class CreateRemoteServers < ActiveRecord::Migration
  def change
    create_table :remote_servers do |t|
      t.string :description
      t.string :user
      t.string :password
      t.string :path

      t.timestamps
    end
  end
end
