require_relative '../../lib/bitbucket/bitbucket'

namespace :bitbucket do
  task commits_sync: :environment do
    bitbucket = Bitbucket.new(url: ENV['BITBUCKET_URL'],
                              username: ENV['BITBUCKET_USERNAME'],
                              password: ENV['BITBUCKET_PASSWORD'])
    projects = bitbucket.projects
    projects.each do |project|
      print "Discovery repos of project: #{project['key']}\n"
      repositories = bitbucket.repositories(project['key'])
      repositories.each do |repository|
        last_commit = BitbucketCommit.where(project_key: project['key'], 
                                            repo_slug: repository['slug']).order(date: :desc).first
        if last_commit
          print "Last commit of repository: #{repository['slug']} is #{last_commit.commit_id}\n"
          commits = bitbucket.commits(project['key'], repository['slug'], last_commit.commit_id)
        else
          print "Discovery all commits of repository: #{repository['slug']}\n"
          commits = bitbucket.commits(project['key'], repository['slug'])
        end
        commits.each do |commit|
          if last_commit && commit['id'] == last_commit.commit_id
            print "Commit in database: #{last_commit.commit_id} and #{commit['id']} equal, skip adding\n"
          else
            print "Saving commit #{commit['id']} of repository: #{project['key']} #{repository['slug']}\n"
            begin
              BitbucketCommit.create(
                commit_id: commit['id'],
                author: commit['author']['emailAddress'],
                message: commit['message'],
                date: Time.at(commit['authorTimestamp'] / 1000),
                project_key: project['key'],
                repo_slug: repository['slug']
              )
            rescue ActiveRecord::RecordNotUnique
              print "Commit #{commit['id']} already exists, skipping\n"
            end
          end
        end
      end
    end
  end
end
