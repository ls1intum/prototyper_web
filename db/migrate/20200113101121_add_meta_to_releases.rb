class AddMetaToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :meta, :string
  end
end
