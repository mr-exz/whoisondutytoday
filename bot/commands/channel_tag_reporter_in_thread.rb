module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelTagReporterInThread < SlackRubyBot::Commands::Base

      DESCRIPTION = 'Enable or disable tagging the reporter in the thread.'.freeze
      EXAMPLE = 'example `channel tag_reporter_enabled=true` or `channel tag_reporter_enabled=false`'.freeze

      def self.call(client:, data:, match:)
        value = match['expression'].split('=').last.strip

        unless %w[true false].include?(value)
          client.say(channel: data.channel, text: "Invalid value for tagging the reporter. Please use 'true' or 'false'.")
          return
        end

        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(tag_reporter_enabled: value)
        channel.save

        client.say(
          channel: data.channel,
          text: "Tagging the reporter in the thread has been set to '#{value}'.",
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end