class AddCompletedToFeedback < ActiveRecord::Migration
  def change
    add_column :feedbacks, :completed, :boolean, default: false
  end
end
