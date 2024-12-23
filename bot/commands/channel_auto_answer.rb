module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelAutoAnswer < SlackRubyBot::Commands::Base
      DESCRIPTION = 'Bot will answer on any message in channel at working time'.freeze
      EXAMPLE = 'channel auto_answer_enabled=<boolean> example `channel auto_answer_enabled=true`'.freeze

      def self.call(client:, data:, match:)
        value = match['expression'].split('=').last.strip

        unless %w[true false].include?(value)
          client.say(
            channel: data.channel,
            text: "Invalid value for auto-answer. Please use 'true' or 'false'.",
            thread_ts: data.thread_ts || data.ts
          )
          return
        end

        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(auto_answer_enabled: value)
        channel.save

        client.say(
          channel: data.channel,
          text: "Channel auto-answer has been set to '#{value}'.",
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end