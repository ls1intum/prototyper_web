class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.string :ipa_url
      t.string :manifest_url
      t.references :release

      t.timestamps null: false
    end
  end
end
