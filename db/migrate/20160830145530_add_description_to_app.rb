class AddDescriptionToApp < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :description, :string
  end
end
