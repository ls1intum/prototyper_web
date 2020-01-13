class AddBundleVersionToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :bundle_version, :string
  end
end
