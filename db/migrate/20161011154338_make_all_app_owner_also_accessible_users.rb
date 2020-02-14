class MakeAllAppOwnerAlsoAccessibleUsers < ActiveRecord::Migration[4.2]
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
