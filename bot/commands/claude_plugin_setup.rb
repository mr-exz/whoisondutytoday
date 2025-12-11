require 'json'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ClaudePluginSetup
      DESCRIPTION = 'Setup Claude plugins by running setup.sh from plugin repo'.freeze
      EXAMPLE = '`claude-plugins setup`'.freeze

      def self.call(client:, data:, match: nil)
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: 'Setting up Claude plugins...',
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )

        # Start background thread to avoid blocking
        Thread.new do
          begin
            # Run setup script
            output = `bash #{script_path} 2>&1`

            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "✅ Claude plugins setup complete\n\n```\n#{output}\n```",
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
          rescue StandardError => e
            puts "Error in ClaudePluginSetup: #{e.class} - #{e.message}"
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
        plugins_dir = ENV['PLUGINS_DIR'] || '/opt/app/plugins'
        File.join(plugins_dir, 'setup.sh')
      end
    end
  end
end
