require 'json'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ClaudePluginSync
      DESCRIPTION = 'Sync Claude plugin repository and return head commit'.freeze
      EXAMPLE = '`claude-plugins sync`'.freeze

      def self.call(client:, data:, match: nil)
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: 'Syncing Claude plugin repository...',
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )

        # Start background thread to avoid blocking
        Thread.new do
          begin
            # Run sync script
            output = `bash #{script_path} 2>&1`

            result = JSON.parse(output)

            if result['success']
              status = result['updated'] ? '✅ Updated' : 'ℹ️ Already up to date'

              message = "#{status}\n" \
                        "Commit: `#{result['hash']}`\n" \
                        "Author: #{result['author']}\n" \
                        "Date: #{result['date']}\n" \
                        "Message: #{result['message']}"

              if result['install_output'] && !result['install_output'].strip.empty?
                message += "\n\n*Plugin Installation Output:*\n```\n#{result['install_output']}\n```"
              end

              client.web_client.chat_postMessage(
                channel: data.channel,
                text: message,
                thread_ts: data.thread_ts || data.ts,
                as_user: true
              )
            else
              client.web_client.chat_postMessage(
                channel: data.channel,
                text: "❌ Sync failed: #{result['error']}",
                thread_ts: data.thread_ts || data.ts,
                as_user: true
              )
            end
          rescue JSON::ParserError => e
            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "❌ Parse error: #{e.message}",
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
          rescue StandardError => e
            puts "Error in ClaudePluginSync: #{e.class} - #{e.message}"
            puts e.backtrace
            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "❌ Error: #{e.message}",
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
          end
        end
      end

      private

      def self.script_path
        Rails.root.join('scripts', 'sync_claude_plugins.sh').to_s
      end
    end
  end
end
