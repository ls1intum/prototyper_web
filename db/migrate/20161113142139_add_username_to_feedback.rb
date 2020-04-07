class AddUsernameToFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :feedbacks, :username, :string
  end
end
