class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.string :type
      t.string :version
      t.text :description
      t.string :build_identifier
      t.references :app, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
