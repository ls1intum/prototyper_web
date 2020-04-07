class CreateDownloadTokens < ActiveRecord::Migration[4.2]
  def change
    create_table :download_tokens do |t|
      t.references :release, index: true, foreign_key: true
      t.references :group, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.boolean :isMainRelease
      t.string :digest

      t.timestamps null: false
    end
  end
end
