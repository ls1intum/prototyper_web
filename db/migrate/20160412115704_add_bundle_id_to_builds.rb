class AddBundleIdToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :bundle_id, :string
  end
end
