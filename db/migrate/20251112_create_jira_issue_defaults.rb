class CreateJiraIssueDefaults < ActiveRecord::Migration[6.0]
  def change
    create_table :jira_issue_defaults do |t|
      t.string :project_key, null: false
      t.json :default_fields, default: {}
      t.timestamps
    end

    add_index :jira_issue_defaults, :project_key, unique: true
  end
end
