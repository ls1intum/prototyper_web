class CreateReleaseLogs < ActiveRecord::Migration
  def change
    create_table :release_logs do |t|
      t.references :group, index: true, foreign_key: true
      t.references :release, index: true, foreign_key: true
      t.boolean :is_main_release
      t.string :changelog

      t.timestamps null: false
    end
  end
end
