class CreateDownloads < ActiveRecord::Migration[4.2]
  def change
    create_table :downloads do |t|
      t.references :release, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
