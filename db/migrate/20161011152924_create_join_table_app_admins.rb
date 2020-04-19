class CreateJoinTableAppAdmins < ActiveRecord::Migration[4.2]
  def change
    create_join_table :apps, :users do |t|
      t.index [:app_id, :user_id]
      t.index [:user_id, :app_id]
    end
  end
end
