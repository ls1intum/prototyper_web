class AddSlackChannelToApp < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :slack_channel, :string
  end
end
