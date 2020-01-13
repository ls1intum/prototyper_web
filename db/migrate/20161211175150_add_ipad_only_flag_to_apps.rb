class AddIpadOnlyFlagToApps < ActiveRecord::Migration
  def change
    add_column :apps, :ipad_only, :boolean
  end
end
