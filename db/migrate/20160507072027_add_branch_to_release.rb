class AddBranchToRelease < ActiveRecord::Migration
  def change
    add_column :releases, :bamboo_branch, :string
  end
end
