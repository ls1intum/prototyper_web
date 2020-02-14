class AddBambooPropertiesToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :bamboo_project, :string
    add_column :apps, :bamboo_plan, :string
  end
end
