class CreateWorkingCopies < ActiveRecord::Migration
  def change
    create_table :working_copies do |t|
      t.integer :repository_id
      t.string :location
      t.string :user
      t.string :password
      t.string :status
      t.string :current_revision

      t.timestamps
    end
  end
end
