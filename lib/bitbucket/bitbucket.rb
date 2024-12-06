require 'faraday'
require 'json'

# Class to operate with Bitbucket Datacenter Api
class Bitbucket
  def initialize(options = {})
    @url = options.fetch(:url, '') # 'https://bitbucket-datacenter.example.com'
    @username = options.fetch(:username, '')
    @password = options.fetch(:password, '')
    @client = Faraday.new(url: @url) do |conn|
      conn.adapter Faraday.default_adapter # make requests with Net::HTTP
      conn.set_basic_auth(@username, @password)
    end
    @logger = Logger.new(STDOUT)
  end

  def fetch_data(endpoint, params = {})
    response = @client.get(endpoint, params)
    unless response.success?
      @logger.error("Failed to fetch data from #{endpoint}: #{response.status}")
      return []
    end

    begin
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      @logger.error("Failed to parse JSON response from #{endpoint}: #{e.message}")
      @logger.error("Response body: #{response.body}")
      return []
    end
  end

  def projects
    projects = []
    start = 0
    limit = 1000

    loop do
      response = @client.get('/rest/api/1.0/projects',start: start, limit: limit)
      return unless response.success?

      data = JSON.parse(response.body)
      projects.concat(data['values'])
      break if data['isLastPage']

      start = data['nextPageStart']
    end
    projects
  end

  def repositories(project_key)
    repositories = []
    start = 0
    limit = 1000

    loop do
      response = @client.get("/rest/api/1.0/projects/#{project_key}/repos", start: start, limit: limit)
      break unless response.success?

      data = JSON.parse(response.body)
      repositories.concat(data['values'])

      break if data['isLastPage']

      start = data['nextPageStart']
    end

    repositories
  end

  def branches(project_key, repo_slug)
    branches = []
    start = 0
    limit = 1000

    loop do
      response = @client.get("/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/branches", start: start, limit: limit)
      break unless response.success?

      data = JSON.parse(response.body)
      branches.concat(data['values'])

      break if data['isLastPage']

      start = data['nextPageStart']
    end

    branches
  end

  def commits(project_key, repo_slug, since_commit = nil)
    commits = []
    start = 0
    limit = 1000
    params = { start: start, limit: limit }
    params[:until] = since_commit if since_commit

    loop do
      data = fetch_data("/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/commits", params)
      break if data.empty?

      commits.concat(data['values'])
      break if data['isLastPage']

      params[:start] = data['nextPageStart']
    end

    commits
  end

  def commit_count(commits)
    commits.size
  end

  def pull_requests(project_key, repo_slug, state = 'ALL')
    pull_requests = []
    start = 0
    limit = 1000
    params = { start: start, limit: limit, state: state }

    loop do
      response = @client.get("/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/pull-requests", params)
      break unless response.success?

      data = JSON.parse(response.body)
      pull_requests.concat(data['values'])

      break if data['isLastPage']

      params[:start] = data['nextPageStart']
    end

    pull_requests
  end

  def pull_request_commits(project_key, repo_slug, pull_request_id)
    commits = []
    start = 0
    limit = 1000
    params = { start: start, limit: limit }

    loop do
      data = fetch_data("/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/pull-requests/#{pull_request_id}/commits", params)
      break if data.empty?

      commits.concat(data['values'])
      break if data['isLastPage']

      params[:start] = data['nextPageStart']
    end

    commits
  end

  def all_branches_commits(project_key, repo_slug, max_threads = 10)
    all_commits = []
    branches = branches(project_key, repo_slug)
    @logger.info("Discovered #{branches.count} branches")
    mutex = Mutex.new
    queue = Queue.new

    branches.each { |branch| queue << branch }

    workers = (1..max_threads).map do
      Thread.new do
        until queue.empty?
          branch = begin
            queue.pop(true)
          rescue StandardError
            nil
          end
          next unless branch

          @logger.info("Discovery commits of branch: #{branch['id']}")
          branch_commits = commits(project_key, repo_slug, branch['id'])
          @logger.info("Discovered #{commit_count(branch_commits)} commits of branch: #{branch['id']}")
          mutex.synchronize do
            all_commits.concat(branch_commits)
          end
        end
      end
    end

    workers.each(&:join)
    all_commits
  end

  def all_pull_request_commits(project_key, repo_slug, max_threads = 10)
    all_commits = []
    pull_requests = pull_requests(project_key, repo_slug)
    @logger.info("Discovered #{pull_requests.count} pull requests")
    mutex = Mutex.new
    queue = Queue.new

    pull_requests.each { |pr| queue << pr }

    workers = (1..max_threads).map do
      Thread.new do
        until queue.empty?
          pr = begin
            queue.pop(true)
          rescue StandardError
            nil
          end
          next unless pr

          @logger.info("Discovery commits of pull request: #{pr['id']}")
          pr_commits = pull_request_commits(project_key, repo_slug, pr['id'])
          @logger.info("Discovered #{commit_count(pr_commits)} commits of pull request: #{pr['id']}")
          mutex.synchronize do
            all_commits.concat(pr_commits)
          end
        end
      end
    end

    workers.each(&:join)
    all_commits
  end

  def all_commits(project_key, repo_slug)
    all_commits = []
    all_commits.concat(all_branches_commits(project_key, repo_slug))
    all_commits.concat(all_pull_request_commits(project_key, repo_slug))
    all_commits
  end

end
