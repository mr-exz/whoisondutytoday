module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelPromptGet
      DESCRIPTION = 'View custom prompt for current channel'.freeze
      EXAMPLE = '`channel prompt get`'.freeze

      def self.call(client:, data:, match: nil)
        begin
          prompt = ::ChannelPrompt.get_prompt(data.channel)

          if prompt
            # Split long prompts to respect Slack's 4000 character limit
            if prompt.length > 3800
              client.web_client.chat_postMessage(
                channel: data.channel,
                text: "📝 Channel prompt (#{prompt.length} characters):\n```\n#{prompt[0..3700]}...\n```",
                thread_ts: data.thread_ts || data.ts,
                as_user: true
              )
            else
              client.web_client.chat_postMessage(
                channel: data.channel,
                text: "📝 Channel prompt:\n```\n#{prompt}\n```",
                thread_ts: data.thread_ts || data.ts,
                as_user: true
              )
            end
          else
            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "ℹ️ No custom prompt set for this channel. Using default prompt.",
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
          end
        rescue StandardError => e
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "❌ Error retrieving prompt: #{e.message}",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end
