class RenameColumnsInBuilds < ActiveRecord::Migration[4.2]
  def change
    rename_column :builds, :ipa_url, :ipa
  end
end
