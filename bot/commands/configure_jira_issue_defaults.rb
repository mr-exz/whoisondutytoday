require 'json'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ConfigureJiraIssueDefaults
      DESCRIPTION = 'Configure default JIRA fields for a project'.freeze
      EXAMPLE = 'configure jira issue defaults PROJECT_KEY {"components":[{"name":"na"}],"priority":{"name":"Minor"}}'.freeze

      def self.call(client:, data:, match: nil)
        # Parse: "configure jira issue defaults PROJECT_KEY {json}"
        unless match
          client.say(
            text: ':warning: Usage: `configure jira issue defaults PROJECT_KEY {JSON with field overrides}`',
            channel: data.channel,
            thread_ts: data['thread_ts']
          )
          return
        end

        # Extract project key and JSON config from the match
        match_str = match.to_s.strip

        # Find the JSON part by looking for the opening {
        json_start = match_str.index('{')

        unless json_start
          client.say(
            text: ':warning: Usage: `configure jira issue defaults PROJECT_KEY {JSON}`',
            channel: data.channel,
            thread_ts: data['thread_ts']
          )
          return
        end

        # Everything before { should contain the project key
        before_json = match_str[0...json_start].strip
        json_config = match_str[json_start..-1]

        # Get the last word before the JSON as the project key
        project_key = before_json.split.last&.upcase

        unless project_key
          client.say(
            text: ':warning: Usage: `configure jira issue defaults PROJECT_KEY {JSON}`',
            channel: data.channel,
            thread_ts: data['thread_ts']
          )
          return
        end

        # Parse JSON
        begin
          fields_config = JSON.parse(json_config)
        rescue JSON::ParserError => e
          client.say(
            text: ":x: Invalid JSON: #{e.message}",
            channel: data.channel,
            thread_ts: data['thread_ts']
          )
          return
        end

        # Save to database
        begin
          config = JiraIssueDefault.set_defaults(project_key, fields_config)

          client.say(
            text: ":white_check_mark: JIRA defaults configured for #{project_key}:\n```\n#{JSON.pretty_generate(fields_config)}\n```",
            channel: data.channel,
            thread_ts: data['thread_ts']
          )

          puts "[CONFIG] Updated JIRA defaults for #{project_key}: #{fields_config.inspect}"
        rescue StandardError => e
          client.say(
            text: ":x: Error saving configuration: #{e.message}",
            channel: data.channel,
            thread_ts: data['thread_ts']
          )
          puts "[ERROR] configure_jira_issue_defaults: #{e.class} - #{e.message}"
        end
      end
    end
  end
end
