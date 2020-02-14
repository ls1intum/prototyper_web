class AddBranchToRelease < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :bamboo_branch, :string
  end
end
