module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelReminder < SlackRubyBot::Commands::Base
      DESCRIPTION = 'Enable or disable channel reminder feature. Bot will remind you about threads without your response'.freeze
      EXAMPLE = '`channel reminder_enabled <boolean>` example `channel reminder_enabled true`'.freeze

      def self.call(client:, data:, match:)
        value = match['expression']

        unless %w[true false].include?(value)
          client.say(
            channel: data.channel, 
            text: "Invalid value for reminder_enabled. Please use 'true' or 'false'.",
            thread_ts: data.thread_ts || data.ts
          )
          return
        end

        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(reminder_enabled: value)
        channel.save

        client.say(
          channel: data.channel,
          text: "Channel reminder_enabled has been set to '#{value}'.",
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
