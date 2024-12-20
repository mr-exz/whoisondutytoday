module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelTagReporterInThreadEnable < SlackRubyBot::Commands::Base

      DESCRIPTION = 'Bot will tag the reporter in the thread.'.freeze
      EXAMPLE = 'Usage: `channel tag reporter in thread enable`'.freeze
      def self.call(client:, data:)
        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(tag_reporter_enabled: true)
        channel.save
        client.say(
          channel: data.channel,
          text: 'Tagging the reporter in the thread has been enabled.',
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end