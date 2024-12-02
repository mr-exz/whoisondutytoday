class CreateBitbucketCommits < ActiveRecord::Migration[6.1]
  def change
    create_table :bitbucket_commits do |t|
      t.string :commit_id
      t.string :author
      t.text :message
      t.datetime :date
      t.string :project_key
      t.string :repo_slug

      t.timestamps
    end
    add_index :bitbucket_commits, [:project_key, :repo_slug, :commit_id], unique: true, name: 'index_bitbucket_commits_on_project_repo_commit'
  end
end
