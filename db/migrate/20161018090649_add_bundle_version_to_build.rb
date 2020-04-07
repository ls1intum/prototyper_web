class AddBundleVersionToBuild < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :bundle_version, :string
  end
end
