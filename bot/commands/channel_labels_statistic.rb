module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelLabelsStatistic
      def self.call(client:, data:, match:)
        start_date = (Time.now - 7.days).beginning_of_week
        end_date = (Time.now - 7.days).end_of_week
        m = SlackThread.joins(:labels).where(channel_id: data.channel).where('thread_ts BETWEEN ? AND ?', start_date.to_time.to_i, end_date.to_time.to_i).group(:label)

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t("commands.thread.statistic",start_date:start_date,end_date:end_date,labels:m.count.to_s),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
