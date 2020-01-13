class MakeAllAppOwnerAlsoAccessibleUsers < ActiveRecord::Migration
  def up
    App.find_each do |app|
      user = app.user
      user.administratable_apps << app
      user.save!
    end
  end

  def down
    # remove_column, change_columns, etc...
  end
end
