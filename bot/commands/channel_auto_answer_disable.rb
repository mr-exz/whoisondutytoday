module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelAutoAnswerDisable < SlackRubyBot::Commands::Base
      def self.call(client:, data:)
        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(auto_answer_enabled: false)
        channel.save
        client.say(
          channel: data.channel,
          text: 'Auto answer has been enabled for this disabled.',
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end