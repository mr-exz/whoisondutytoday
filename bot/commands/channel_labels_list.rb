module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelLabelsList
      DESCRIPTION = 'Will display all labels in this channel.'.freeze
      EXAMPLE = '`channel labels list`'.freeze
      def self.call(client:, data:, match:)
        m = SlackThread.joins(:labels).where(channel_id: data.channel).group(:label).count.keys
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: m.to_s,
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
