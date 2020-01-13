class RenameColumnInReleases < ActiveRecord::Migration
  def change
    rename_column :releases, :container_url, :container_path
  end
end
