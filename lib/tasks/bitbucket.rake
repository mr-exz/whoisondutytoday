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
        commits = []
        logger.info("Discovery commits of git repo #{project['key']}:#{repository['slug']}")

        # Get the most recent commit from the database
        last_commit_created = BitbucketCommit.where(project_key: project['key'],
                                                    repo_slug: repository['slug']).order(created_at: :desc).first

        last_commit_by_date = BitbucketCommit.where(project_key: project['key'],
                                                    repo_slug: repository['slug']).order(date: :desc).first

        last_branch_date = bitbucket.last_branch_created_date(project['key'], repository['slug'])
        last_pr_date = bitbucket.last_pull_request_created_date(project['key'], repository['slug'])

        if last_commit_created && last_commit_created.created_at > 24.hours.ago
          next_allowed_sync_date = last_commit_created.created_at + 24.hours
          logger.info("#{project['key']}:#{repository['slug']} last sync date:#{last_commit_created.created_at} next will be after:#{next_allowed_sync_date}, skipping")
          next
        end

        if last_commit_by_date && last_commit_by_date.date >= last_branch_date
          logger.info("#{project['key']}:#{repository['slug']} last commits: #{last_commit_by_date.date} last branch: #{last_branch_date}, branch commits skipped")
        elsif
          logger.info("#{project['key']}:#{repository['slug']} last branch: #{last_branch_date}, syncking branches")
          commits.concat(bitbucket.all_branches_commits(project['key'], repository['slug']))
        end

        if last_commit_by_date && last_commit_by_date.date >= last_pr_date
          logger.info("#{project['key']}:#{repository['slug']} last commits: #{last_commit_by_date.date} last pr: #{last_pr_date}, pr commits skipped")
        elsif
          logger.info("#{project['key']}:#{repository['slug']} last pr: #{last_pr_date}, synking prs")
          commits.concat(bitbucket.all_pull_request_commits(project['key'], repository['slug']))
        end

        commits = commits.uniq { |commit| commit['id'] }
        # Get all existing commit IDs from the database
        existing_commit_ids = BitbucketCommit.where(project_key: project['key'],
                                                    repo_slug: repository['slug']).pluck(:commit_id)

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
