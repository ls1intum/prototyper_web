class AddReleasesToGroups < ActiveRecord::Migration[4.2]
  def change
    add_reference :groups, :main_release, references: :releases, index: true, foreign_key: true
    add_reference :groups, :second_release, references: :releases, index: true, foreign_key: true
  end
end
