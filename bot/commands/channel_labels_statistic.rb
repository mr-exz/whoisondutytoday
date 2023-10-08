module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelLabelsStatistic
      def self.call(client:, data:, match:)
        m=Message.joins(:labels).where(channel_id: data.channel).group(:label)

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: m.count.to_s,
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
