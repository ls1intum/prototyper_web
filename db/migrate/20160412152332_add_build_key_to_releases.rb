class AddBuildKeyToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :build_key, :string
  end
end
