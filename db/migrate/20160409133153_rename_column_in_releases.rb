class RenameColumnInReleases < ActiveRecord::Migration[4.2]
  def change
    rename_column :releases, :container_url, :container_path
  end
end
