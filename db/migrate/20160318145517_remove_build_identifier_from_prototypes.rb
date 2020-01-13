class RemoveBuildIdentifierFromPrototypes < ActiveRecord::Migration
  def change
    remove_column :releases, :build_identifier
  end
end
