class AddIpadOnlyFlagToApps < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :ipad_only, :boolean
  end
end
