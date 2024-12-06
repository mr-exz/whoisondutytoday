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
        last_commit_created = BitbucketCommit.where(project_key: project['key'],
                                            repo_slug: repository['slug']).order(created_at: :desc).first

        last_commit_by_date = BitbucketCommit.where(project_key: project['key'],
                                                    repo_slug: repository['slug']).order(date: :desc).first

        # Skip sync if the last commit was added less than 24 hours ago
        if last_commit_created && last_commit_created.created_at < 24.hours.ago
          logger.info("Skipping sync for repository: #{project['key']}:#{repository['slug']} as the last commit was added #{last_commit_created.created_at} less than 24 hours ago")
          next
        end

        last_branch_date=bitbucket.last_branch_created_date(project['key'], repository['slug'])
        logger.info("Last branch of repository: #{project['key']}:#{repository['slug']} is #{last_branch_date}")

        last_pr_date=bitbucket.last_pull_request_created_date(project['key'], repository['slug'])
        logger.info("Last pull request of repository: #{project['key']}:#{repository['slug']} is #{last_pr_date}")

        if last_commit_by_date && (last_commit_by_date.date >= last_branch_date && last_commit_by_date.date >= last_pr_date)
          logger.info("Skipping sync for repository: #{project['key']}:#{repository['slug']} as the last commit was added #{last_commit_by_date.date} after the last branch and pull request")
          next
        elsif last_commit_by_date
          logger.info("Syncing commits for repository: #{project['key']}:#{repository['slug']} synce last commit was added #{last_commit_by_date.date} before the last branch and pull request")
        else
          logger.info("Syncing commits for repository: #{project['key']}:#{repository['slug']} as there is no last commit date available")
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
