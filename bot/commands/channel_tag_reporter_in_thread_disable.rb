module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelTagReporterInThreadDisable < SlackRubyBot::Commands::Base

      DESCRIPTION = 'Bot will not tag the reporter in the thread.'.freeze
      EXAMPLE = 'Usage: `channel tag reporter in thread disable`'.freeze
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