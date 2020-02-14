class AddJiraToApp < ActiveRecord::Migration[4.2]
  def change
    add_column :apps, :jira_project_id, :string
  end
end
