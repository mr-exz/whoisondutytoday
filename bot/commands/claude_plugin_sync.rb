require 'json'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ClaudePluginSync
      DESCRIPTION = 'Sync Claude plugin repository and return head commit'.freeze
      EXAMPLE = '`claude plugin sync`'.freeze

      def self.call(client:, data:, match: nil)
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: 'Syncing Claude plugin repository...',
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )

        # Run sync script
        output = `bash #{script_path} 2>&1`

        begin
          result = JSON.parse(output)

          if result['success']
            status = result['updated'] ? '✅ Updated' : 'ℹ️ Already up to date'

            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "#{status}\n" \
                    "Commit: `#{result['hash']}`\n" \
                    "Author: #{result['author']}\n" \
                    "Date: #{result['date']}\n" \
                    "Message: #{result['message']}",
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
        rescue JSON::ParserError
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "❌ Error: #{output}",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end

      private

      def self.script_path
        Rails.root.join('scripts', 'sync_claude_plugins.sh').to_s
      end
    end
  end
end
