module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelReminder < SlackRubyBot::Commands::Base
      DESCRIPTION = 'Enable or disable channel reminders.'.freeze
      EXAMPLE = 'example `channel reminder=true` or `channel reminder=false`'.freeze

      def self.call(client:, data:, match:)
        value = match['expression'].split('=').last.strip

        unless %w[true false].include?(value)
          client.say(channel: data.channel, text: "Invalid value for reminder. Please use 'true' or 'false'.")
          return
        end

        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(reminder_enabled: value)
        channel.save

        client.say(
          channel: data.channel,
          text: "Channel reminder has been set to '#{value}'.",
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
