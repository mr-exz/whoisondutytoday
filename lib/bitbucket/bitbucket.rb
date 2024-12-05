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
      response = @client.get("/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/commits", params)
      break unless response.success?

      data = JSON.parse(response.body)
      commits.concat(data['values'])

      break if data['isLastPage']

      params[:start] = data['nextPageStart']
    end

    commits
  end

  def commit_count(commits)
    commits.size
  end
end
