module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelPromptDelete
      DESCRIPTION = 'Delete custom prompt for current channel'.freeze
      EXAMPLE = '`channel prompt delete`'.freeze

      def self.call(client:, data:, match: nil)
        begin
          ::ChannelPrompt.delete_prompt(data.channel)

          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "✅ Channel prompt deleted. Will use default prompt next time.",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        rescue StandardError => e
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "❌ Error deleting prompt: #{e.message}",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end
