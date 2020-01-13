class CreateJoinTableAppAdmins < ActiveRecord::Migration
  def change
    create_join_table :Apps, :Users do |t|
      t.index [:app_id, :user_id]
      t.index [:user_id, :app_id]
    end
  end
end
