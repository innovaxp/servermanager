class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :description
      t.string :master_location
      t.string :slave_location
      t.integer :current_version
      t.string :user
      t.string :password

      t.timestamps
    end
  end
end
