class AddBuildKeyToReleases < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :build_key, :string
  end
end
