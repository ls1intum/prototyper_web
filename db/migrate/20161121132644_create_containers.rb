class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :marvel_url
      t.string :container_path
      t.references :app, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
