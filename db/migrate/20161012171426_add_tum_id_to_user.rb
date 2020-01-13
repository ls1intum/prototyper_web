class AddTumIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :tum_id, :string
  end
end
