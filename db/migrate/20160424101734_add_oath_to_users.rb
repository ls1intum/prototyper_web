class AddOathToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :bamboo_token, :string
    add_column :users, :bamboo_secret, :string
  end
end
