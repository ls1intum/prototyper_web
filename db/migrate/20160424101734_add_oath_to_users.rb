class AddOathToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bamboo_token, :string
    add_column :users, :bamboo_secret, :string
  end
end
