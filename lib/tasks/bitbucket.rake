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
        print "Discovery commits of git repo #{project['key']}:#{repository['slug']}\n"

        # Get all existing commit IDs from the database
        existing_commit_ids = BitbucketCommit.where(project_key: project['key'],
                                                    repo_slug: repository['slug']).pluck(:commit_id)

        commits = bitbucket.all_commits(project['key'], repository['slug'])
        # Filter out commits that already exist in the database
        new_commits = commits.reject { |commit| existing_commit_ids.include?(commit['id']) }
        print "#{new_commits.count} new commits to save\n"

        new_commits.each do |commit|
          BitbucketCommit.create(
            commit_id: commit['id'],
            author: commit['author']['emailAddress'],
            message: commit['message'],
            date: Time.at(commit['authorTimestamp'] / 1000),
            project_key: project['key'],
            repo_slug: repository['slug']
          )
          print "Commit #{commit['id']} of repository: #{project['key']}:#{repository['slug']} saved\n"
        rescue ActiveRecord::RecordNotUnique
          print "Commit #{commit['id']} of repository: #{project['key']}:#{repository['slug']} already exist\n"
        end
      end
    end
  end
end
