class AddAdminAndWritePermissionsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :admin, :boolean, :default => false
    add_column :users, :write_permissions, :boolean, :default => false
  end
end
