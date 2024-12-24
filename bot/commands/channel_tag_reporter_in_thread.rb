module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelTagReporterInThread < SlackRubyBot::Commands::Base

      DESCRIPTION = 'Enable or disable tagging the reporter in the thread.'.freeze
      EXAMPLE = '`channel tag_reporter_enabled <boolean>` example `channel tag_reporter_enabled true`'.freeze

      def self.call(client:, data:, match:)
        value = match['expression']

        unless %w[true false].include?(value)
          client.say(
            channel: data.channel,
            text: "Invalid value for tag_reporter_enabled. Please use 'true' or 'false'.",
            thread_ts: data.thread_ts || data.ts
          )
          return
        end

        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(tag_reporter_enabled: value)
        channel.save

        client.say(
          channel: data.channel,
          text: "Channel tag_reporter_enabled has been set to '#{value}'.",
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end