class AddUploadKeyToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :upload_key, :string
  end
end
