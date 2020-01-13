class RenameColumnsInBuilds < ActiveRecord::Migration
  def change
    rename_column :builds, :ipa_url, :ipa
  end
end
