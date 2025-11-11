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

    def create_task(project_key:, summary:, description:, priority: 'Low')
      # Create task via API v3
      uri = URI("#{@base_url}/rest/api/3/issues")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = auth_header

      payload = {
        fields: {
          project: { key: project_key },
          summary: summary,
          description: {
            version: 3,
            type: 'doc',
            content: [
              {
                type: 'paragraph',
                content: [
                  {
                    type: 'text',
                    text: description
                  }
                ]
              }
            ]
          },
          issuetype: { name: 'Task' },
          components: [{ name: 'na' }]
        }
      }

      request.body = JSON.generate(payload)
      response = http.request(request)

      if response.is_a?(Net::HTTPCreated)
        JSON.parse(response.body)
      else
        puts "[JIRA Error] #{response.code}: #{response.body[0..300]}"
        nil
      end
    rescue StandardError => e
      puts "[JIRA Client Error] #{e.class} - #{e.message}"
      puts e.backtrace.join("\n")
      nil
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
