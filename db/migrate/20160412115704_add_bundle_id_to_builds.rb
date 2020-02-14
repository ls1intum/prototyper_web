class AddBundleIdToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :bundle_id, :string
  end
end
