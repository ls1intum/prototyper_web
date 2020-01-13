class AddJiraToApp < ActiveRecord::Migration
  def change
    add_column :apps, :jira_project_id, :string
  end
end
