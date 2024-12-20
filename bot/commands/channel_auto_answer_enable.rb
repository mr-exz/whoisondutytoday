module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelAutoAnswerEnable < SlackRubyBot::Commands::Base

      DESCRIPTION = 'Bot will answer on any message in channel at working time'.freeze
      EXAMPLE = 'Usage: `channel auto answer enable`'.freeze
      def self.call(client:, data:)
        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(auto_answer_enabled: true)
        channel.save
        client.say(
          channel: data.channel,
          text: 'Auto answer has been enabled for this channel.',
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end