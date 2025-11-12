require_relative '../../lib/jira/jira_client'
require_relative '../../lib/claude/summarizer'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class JiraCreateTask
      DESCRIPTION = 'Create a JIRA task from a Slack thread with Claude summary'.freeze
      EXAMPLE = 'create jira task in PROJECT_KEY from thread'.freeze

      def self.call(client:, data:, match: nil)
        # Validate command is in a thread
        unless data.key?('thread_ts')
          client.say(
            text: ':warning: The `create jira task` command only works in threads.',
            channel: data.channel
          )
          return
        end

        # Parse project key from match (e.g., "in PROJECT_KEY from thread")
        project_key = extract_project_key(match)
        unless project_key
          client.say(
            text: ':warning: Please specify a project. Usage: `create jira task in PROJECT_KEY from thread`',
            channel: data.channel,
            thread_ts: data['thread_ts']
          )
          return
        end

        thread_ts = data['thread_ts']
        channel_id = data.channel

        begin
          # Show processing message
          client.say(
            text: ':hourglass_flowing_sand: Creating JIRA task from thread...',
            channel: channel_id,
            thread_ts: thread_ts
          )

          # Fetch thread messages
          thread_messages = fetch_thread_messages(client, channel_id, thread_ts)

          if thread_messages.empty?
            client.say(
              text: ':x: No messages found in thread.',
              channel: channel_id,
              thread_ts: thread_ts
            )
            return
          end

          # Summarize thread with Claude
          summarizer = ClaudeModule::Summarizer.new
          summary = summarizer.summarize_thread(thread_messages)

          if summary.nil?
            client.say(
              text: ':x: Failed to summarize thread. Please try again.',
              channel: channel_id,
              thread_ts: thread_ts
            )
            return
          end

          # Analyze summary with Claude to get structured JIRA fields
          jira_fields = analyze_for_jira(summarizer, summary)

          if jira_fields.nil?
            client.say(
              text: ':x: Failed to analyze thread for JIRA fields. Please try again.',
              channel: channel_id,
              thread_ts: thread_ts
            )
            return
          end

          # Build Slack thread link
          # Format: https://workspace.slack.com/archives/CHANNEL/pTIMESTAMP
          thread_ts_clean = thread_ts.gsub('.', '')

          begin
            team_info = client.web_client.team_info
            team_id = team_info&.dig('team', 'id')
            domain = team_info&.dig('team', 'domain')

            if domain
              thread_link = "https://#{domain}.slack.com/archives/#{channel_id}/p#{thread_ts_clean}"
            elsif team_id
              thread_link = "https://#{team_id}.slack.com/archives/#{channel_id}/p#{thread_ts_clean}"
            else
              thread_link = "Slack thread"
            end
          rescue StandardError => e
            puts "[ERROR] Failed to get team info: #{e.message}"
            thread_link = "Slack thread"
          end

          # Add Slack thread link to description
          full_description = "#{jira_fields['description']}\n\n---\n\n*Source:* #{thread_link}"

          # Create JIRA issue with Claude-analyzed fields
          jira_client = JiraModule::JiraClient.new
          issue_response = jira_client.create_task(
            project_key: project_key,
            summary: jira_fields['summary'],
            description: full_description,
            priority: jira_fields['priority']
          )

          unless issue_response
            client.say(
              text: ':x: Failed to create JIRA task. Please check JIRA configuration.',
              channel: channel_id,
              thread_ts: thread_ts
            )
            return
          end

          # Extract issue key and create link
          issue_key = issue_response['key']
          jira_link = "#{ENV['JIRA_BASE_URL']}/browse/#{issue_key}"

          # Post success message with link
          client.web_client.chat_postMessage(
            text: ':white_check_mark: JIRA Task Created',
            channel: channel_id,
            thread_ts: thread_ts,
            attachments: [
              {
                fallback: "JIRA Task: #{issue_key}",
                text: "<#{jira_link}|#{issue_key}>",
                color: '#0052CC',
                attachment_type: 'default'
              }
            ],
            as_user: true
          )
        rescue StandardError => e
          puts "[ERROR] create_jira_task: #{e.class} - #{e.message}"
          puts e.backtrace.join("\n")
          client.say(
            text: ":x: Error: #{e.message}",
            channel: channel_id,
            thread_ts: thread_ts
          )
        end
      end

      private

      def self.extract_project_key(match)
        # Match pattern: "in PROJECT_KEY from thread"
        if match && match.to_s =~ /in\s+(\w+)\s+from\s+thread/i
          ::Regexp.last_match(1).upcase
        end
      end

      def self.fetch_thread_messages(client, channel, thread_ts)
        messages = []

        begin
          response = client.web_client.conversations_replies(
            channel: channel,
            ts: thread_ts,
            inclusive: true,
            limit: 100
          )

          response['messages'].each do |msg|
            next if msg['bot_id'] || msg['subtype'] == 'message_changed'

            user_id = msg['user']
            user_info = fetch_user_info(client, user_id)
            user_name = user_info&.dig('user', 'real_name') || user_info&.dig('user', 'name') || 'Unknown'

            messages << {
              user: user_name,
              text: msg['text'],
              ts: msg['ts']
            }
          end
        rescue StandardError => e
          puts "[ERROR] fetch_thread_messages: #{e.message}"
        end

        messages
      end

      def self.fetch_user_info(client, user_id)
        client.web_client.users_info(user: user_id)
      rescue StandardError => e
        puts "[ERROR] fetch_user_info: #{e.message}"
        nil
      end

      def self.analyze_for_jira(summarizer, summary)
        # Use Claude to analyze the summary and extract JIRA fields
        prompt = <<~PROMPT
          Analyze this thread summary and extract JIRA task fields.
          Return ONLY valid JSON, no markdown, no extra text.

          Summary:
          #{summary}

          Return JSON with these exact fields:
          {
            "summary": "concise title (max 100 chars, human-readable)",
            "description": "detailed description of the issue",
            "priority": "High, Medium, or Low"
          }
        PROMPT

        response = summarizer.analyze_with_claude(prompt)
        return nil unless response

        begin
          # Remove markdown code blocks if present
          json_str = response.gsub(/^```json\s*/, '').gsub(/\s*```$/, '')
          JSON.parse(json_str)
        rescue JSON::ParserError => e
          puts "[ERROR] Failed to parse Claude response as JSON: #{e.message}"
          puts "[DEBUG] Response was: #{response[0..200]}"
          nil
        end
      end

    end
  end
end
