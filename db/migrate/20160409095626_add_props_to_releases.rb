class AddPropsToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :container_url, :string
    add_column :releases, :hide_statusbar, :boolean, default: true
  end
end
