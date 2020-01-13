class AddBambooPropertiesToApps < ActiveRecord::Migration
  def change
    add_column :apps, :bamboo_project, :string
    add_column :apps, :bamboo_plan, :string
  end
end
