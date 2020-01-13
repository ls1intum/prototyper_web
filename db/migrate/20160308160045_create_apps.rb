class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.string :bundle_id
      t.string :icon
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :apps, [:user_id, :created_at]
  end
end
