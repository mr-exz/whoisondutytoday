module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelTagReporterInThreadDisable < SlackRubyBot::Commands::Base
      def self.call(client:, data:)
        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(tag_reporter_enabled: false)
        channel.save
        client.say(
          channel: data.channel,
          text: 'Tagging the reporter in the thread has been disabled.',
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end