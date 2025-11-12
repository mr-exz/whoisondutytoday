require 'net/http'
require 'json'

module ClaudeModule
  class Summarizer
    def initialize
      @base_url = ENV['ANTHROPIC_BASE_URL'] || 'https://api.anthropic.com'
      @auth_token = ENV['ANTHROPIC_AUTH_TOKEN']
      @model = ENV['ANTHROPIC_DEFAULT_SONNET_MODEL'] || 'bedrock-claude-4.5-haiku'

      raise 'ANTHROPIC_AUTH_TOKEN environment variable not set' if @auth_token.nil?
    end

    def summarize_thread(thread_messages)
      return nil if thread_messages.empty?

      # Format messages for Claude
      formatted_messages = format_messages_for_claude(thread_messages)

      # Create the prompt
      prompt = build_summary_prompt(formatted_messages)

      # Call Claude API via HTTP
      response = call_claude_api(prompt)

      # Extract the summary from response
      response&.dig('content', 0, 'text')
    rescue StandardError => e
      puts "Error calling Claude API: #{e.message}"
      puts e.backtrace.join("\n")
      nil
    end

    def analyze_with_claude(prompt)
      # Generic method to send any prompt to Claude and get response
      response = call_claude_api(prompt)
      response&.dig('content', 0, 'text')
    rescue StandardError => e
      puts "Error in analyze_with_claude: #{e.message}"
      nil
    end

    private

    def call_claude_api(prompt)
      uri = URI("#{@base_url}/v1/messages")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{@auth_token}"
      request['anthropic-version'] = '2023-06-01'

      payload = {
        model: @model,
        max_tokens: 1024,
        messages: [
          {
            role: 'user',
            content: prompt
          }
        ]
      }

      request.body = JSON.generate(payload)

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        puts "API Error: #{response.code} - #{response.body}"
        nil
      end
    rescue StandardError => e
      puts "Error in call_claude_api: #{e.message}"
      nil
    end

    def format_messages_for_claude(thread_messages)
      thread_messages.map do |msg|
        "#{msg[:user]}: #{msg[:text]}"
      end.join("\n\n")
    end

    def build_summary_prompt(formatted_messages)
      <<~PROMPT
        Please provide a concise summary of the following Slack thread discussion.
        Focus on key points, decisions made, and action items if any.
        Keep the summary to 2-3 paragraphs maximum.

        Thread messages:
        #{formatted_messages}

        Summary:
      PROMPT
    end
  end
end
