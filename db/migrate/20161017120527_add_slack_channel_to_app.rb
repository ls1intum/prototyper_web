class AddSlackChannelToApp < ActiveRecord::Migration
  def change
    add_column :apps, :slack_channel, :string
  end
end
