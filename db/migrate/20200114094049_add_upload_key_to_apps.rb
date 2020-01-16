class AddUploadKeyToApps < ActiveRecord::Migration
  def change
    add_column :apps, :upload_key, :string
  end
end
