module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelTagReporterInThreadEnable < SlackRubyBot::Commands::Base
      def self.call(client, data, _match)
        channel = Channel.find_by(slack_channel_id: data.channel)
        if channel
          channel.update(tag_reporter: true)
          client.say(channel: data.channel, text: 'Tagging the reporter in the thread has been enabled.')
        else
          client.say(channel: data.channel, text: 'Channel not found.')
        end
      end
    end
  end
end