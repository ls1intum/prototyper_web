class AddUrlToPrototypes < ActiveRecord::Migration
  def change
    add_column :releases, :url, :string
  end
end
