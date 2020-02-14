class RemoveBuildIdentifierFromPrototypes < ActiveRecord::Migration[4.2]
  def change
    remove_column :releases, :build_identifier
  end
end
