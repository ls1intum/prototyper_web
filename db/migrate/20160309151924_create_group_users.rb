class CreateGroupUsers < ActiveRecord::Migration
  def change
    create_table :group_users do |t|
      t.integer :user_id
      t.integer :group_id

      t.timestamps null: false
    end
    add_index :group_users, :user_id
    add_index :group_users, :group_id
    add_index :group_users, [:user_id, :group_id], unique: true
  end
end
