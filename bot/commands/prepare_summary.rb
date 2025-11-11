require_relative '../../lib/claude/summarizer'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class PrepareSummary
      DESCRIPTION = 'Analyze a thread and generate a summary using Claude AI'.freeze
      EXAMPLE = '@cibot prepare summary (in a thread)'.freeze

      def self.call(client:, data:, match: nil)
        # This command should only work in threads
        unless data.key?('thread_ts')
          client.say(
            text: ':warning: The `prepare summary` command only works in threads. Use it in a thread to summarize the discussion.',
            channel: data.channel
          )
          return
        end

        thread_ts = data['thread_ts']

        begin
          # Fetch thread messages from Slack
          thread_messages = fetch_thread_messages(client, data.channel, thread_ts)

          if thread_messages.empty?
            client.say(
              text: ':warning: No messages found in this thread.',
              channel: data.channel,
              thread_ts: thread_ts
            )
            return
          end

          # Show that we're processing
          client.say(
            text: ':hourglass_flowing_sand: Analyzing thread and preparing summary...',
            channel: data.channel,
            thread_ts: thread_ts
          )

          # Summarize using Claude
          summarizer = ClaudeModule::Summarizer.new
          summary = summarizer.summarize_thread(thread_messages)

          if summary.nil?
            client.say(
              text: ':x: Failed to generate summary. Please try again later.',
              channel: data.channel,
              thread_ts: thread_ts
            )
            return
          end

          # Post summary to thread
          client.web_client.chat_postMessage(
            text: ':memo: Thread Summary',
            channel: data.channel,
            thread_ts: thread_ts,
            attachments: [
              {
                fallback: 'Thread Summary',
                text: summary,
                color: '#36a64f',
                attachment_type: 'default'
              }
            ],
            as_user: true
          )
        rescue StandardError => e
          puts "Error in prepare_summary command: #{e.message}"
          puts e.backtrace
          client.say(
            text: ":x: Error: #{e.message}",
            channel: data.channel,
            thread_ts: thread_ts
          )
        end
      end

      private

      def self.fetch_thread_messages(client, channel, thread_ts)
        messages = []

        begin
          # Fetch replies in the thread
          response = client.web_client.conversations_replies(
            channel: channel,
            ts: thread_ts,
            inclusive: true,
            limit: 100
          )

          # Extract message text and user info
          response['messages'].each do |msg|
            # Skip bot messages and edits
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
          puts "Error fetching thread messages: #{e.message}"
        end

        messages
      end

      def self.fetch_user_info(client, user_id)
        client.web_client.users_info(user: user_id)
      rescue StandardError => e
        puts "Error fetching user info for #{user_id}: #{e.message}"
        nil
      end
    end
  end
end
