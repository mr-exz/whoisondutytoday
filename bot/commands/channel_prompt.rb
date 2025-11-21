module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelPrompt
      DESCRIPTION = 'Manage channel-specific prompt for take_a_look command'.freeze
      EXAMPLE = '`channel prompt set <prompt_text>` or `channel prompt get` or `channel prompt delete`'.freeze

      def self.call(client:, data:, match: nil)
        text = data.text.strip

        # Parse command: "channel prompt <action> [prompt_text]"
        # Remove "channel prompt" prefix
        command_text = text.sub(/^\s*channel\s+prompt\s+/i, '').strip

        # Extract action (first word) and everything else (preserving multiline/formatting)
        match_data = command_text.match(/^(\S+)\s*(.*)/m)
        action = match_data[1]&.downcase if match_data
        prompt_text = match_data[2]&.strip if match_data

        case action
        when 'set'
          set_prompt(client, data, prompt_text)
        when 'get'
          get_prompt(client, data)
        when 'delete'
          delete_prompt(client, data)
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "❌ Unknown action: #{action}\n" \
                  "Use: `channel prompt set|get|delete [text]`",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end

      private

      def self.set_prompt(client, data, prompt_text)
        unless prompt_text
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "❌ Prompt text is required for set action",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
          return
        end

        begin
          ::ChannelPrompt.set_prompt(data.channel, prompt_text)

          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "✅ Channel prompt saved successfully\n" \
                  "Length: #{prompt_text.length} characters",
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

      def self.get_prompt(client, data)
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

      def self.delete_prompt(client, data)
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
