class AddUsernameToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :username, :string
  end
end
