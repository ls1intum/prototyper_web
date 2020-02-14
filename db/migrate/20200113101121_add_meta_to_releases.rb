class AddMetaToReleases < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :meta, :string
  end
end
