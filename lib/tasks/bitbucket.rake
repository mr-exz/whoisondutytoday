require_relative '../../lib/bitbucket/bitbucket'
require 'logger'

namespace :bitbucket do
  task commits_sync: :environment do
    logger = Logger.new(STDOUT)
    bitbucket = Bitbucket.new(url: ENV['BITBUCKET_URL'],
                              username: ENV['BITBUCKET_USERNAME'],
                              password: ENV['BITBUCKET_PASSWORD'])
    projects = bitbucket.projects
    projects.each do |project|
      logger.info("Discovery repos of project: #{project['key']}")
      repositories = bitbucket.repositories(project['key'])
      repositories.each do |repository|
        logger.info("Discovery commits of git repo #{project['key']}:#{repository['slug']}")

        # Get the most recent commit from the database
        last_commit = BitbucketCommit.where(project_key: project['key'],
                                            repo_slug: repository['slug']).order(created_at: :desc).first

        # Skip sync if the last commit was added less than 24 hours ago
        if last_commit && last_commit.created_at > 24.hours.ago
          logger.info("Skipping sync for repository: #{project['key']}:#{repository['slug']} as the last commit was added less than 24 hours ago")
          next
        end

        # Get all existing commit IDs from the database
        existing_commit_ids = BitbucketCommit.where(project_key: project['key'],
                                                    repo_slug: repository['slug']).pluck(:commit_id)

        commits = bitbucket.all_commits(project['key'], repository['slug'])
        # Filter out commits that already exist in the database
        new_commits = commits.reject { |commit| existing_commit_ids.include?(commit['id']) }
        logger.info("#{new_commits.count} new commits to save")

        new_commits.each do |commit|
          BitbucketCommit.create(
            commit_id: commit['id'],
            author: commit['author']['emailAddress'],
            message: commit['message'],
            date: Time.at(commit['authorTimestamp'] / 1000),
            project_key: project['key'],
            repo_slug: repository['slug']
          )
          logger.info("Commit #{commit['id']} of repository: #{project['key']}:#{repository['slug']} saved")
        rescue ActiveRecord::RecordNotUnique
          logger.info("Commit #{commit['id']} of repository: #{project['key']}:#{repository['slug']} already exist")
        end
      end
    end
  end
end
