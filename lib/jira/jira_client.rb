require 'net/http'
require 'json'

module JiraModule
  class JiraClient
    def initialize
      @base_url = ENV['JIRA_BASE_URL']
      @api_token = ENV['JIRA_API_TOKEN']

      raise 'JIRA_BASE_URL environment variable not set' if @base_url.nil?
      raise 'JIRA_API_TOKEN environment variable not set' if @api_token.nil?
    end

    def create_task(project_key:, summary:, description:, custom_fields: {})
      create_task_v2(project_key, summary, description, custom_fields)
    rescue StandardError => e
      puts "[JIRA Client Error] #{e.class} - #{e.message}"
      puts e.backtrace.join("\n")
      nil
    end

    def create_task_v2(project_key, summary, description, custom_fields = {})
      uri = URI("#{@base_url}/rest/api/2/issue")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = auth_header

      # Start with custom fields from template (project, priority, component, etc)
      fields = custom_fields.is_a?(Hash) ? custom_fields.dup : {}

      # Always set project key and issue type
      fields[:project] = { key: project_key } unless fields[:project]
      fields[:issuetype] = { name: 'Task' } unless fields[:issuetype]

      # Generated fields always override template (summary and description from Claude)
      fields[:summary] = summary
      fields[:description] = description

      payload = { fields: fields }

      request.body = JSON.generate(payload)
      response = http.request(request)

      if response.is_a?(Net::HTTPCreated)
        puts "[JIRA] Task created: #{response.body}"
        JSON.parse(response.body)
      else
        error_msg = "[JIRA Error] #{response.code}: #{response.body}"
        puts error_msg
        # Return error info so caller can display it
        {
          error: true,
          code: response.code,
          body: response.body,
          message: error_msg
        }
      end
    end

    def get_issue(issue_key)
      uri = URI("#{@base_url}/rest/api/3/issues/#{issue_key}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = auth_header

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        puts "[JIRA Error] Failed to get issue: #{response.code}"
        nil
      end
    rescue StandardError => e
      puts "[JIRA Client Error] #{e.class} - #{e.message}"
      nil
    end

    private

    def auth_header
      "Bearer #{@api_token}"
    end
  end
end
