module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelPromptSet
      DESCRIPTION = 'Set custom prompt for current channel'.freeze
      EXAMPLE = '`prompt set Your custom prompt text here...`'.freeze

      def self.call(client:, data:, match: nil)
        text = data.text.strip
        prompt_text = text.sub(/^\s*prompt\s+set\s+/i, '').strip

        unless prompt_text
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "❌ Prompt text is required",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
          return
        end

        begin
          ::ChannelPrompt.set_prompt(data.channel, prompt_text)

          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "✅ Prompt saved successfully\nLength: #{prompt_text.length} characters",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        rescue StandardError => e
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "❌ Error saving prompt: #{e.message}",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end
