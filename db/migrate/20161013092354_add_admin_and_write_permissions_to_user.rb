class AddAdminAndWritePermissionsToUser < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, :default => false
    add_column :users, :write_permissions, :boolean, :default => false
  end
end
