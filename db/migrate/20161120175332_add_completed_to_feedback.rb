class AddCompletedToFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :feedbacks, :completed, :boolean, default: false
  end
end
