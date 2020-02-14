class AddUrlToPrototypes < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :url, :string
  end
end
