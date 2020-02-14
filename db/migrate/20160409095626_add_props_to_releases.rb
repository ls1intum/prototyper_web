class AddPropsToReleases < ActiveRecord::Migration[4.2]
  def change
    add_column :releases, :container_url, :string
    add_column :releases, :hide_statusbar, :boolean, default: true
  end
end
