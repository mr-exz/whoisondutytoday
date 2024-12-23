module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelLabelsStatistic
      DESCRIPTION = 'Will show the label count in the channel for the last week.'.freeze
      EXAMPLE = '`channel labels statistic`'.freeze
      def self.call(client:, data:, match:)
        message = ''
        (0..8).to_a.each do |x|;
          start_date = (Time.now - x.week).beginning_of_week
          end_date = (Time.now - x.week).end_of_week
          m = SlackThread.joins(:labels).where(channel_id: data.channel).where('thread_ts BETWEEN ? AND ?', start_date.to_time.to_i, end_date.to_time.to_i).group(:label)
          message.concat(I18n.t('commands.thread.statistic',start_date:start_date.strftime('%d.%m.%Y %H:%M'),end_date:end_date.strftime('%d.%m.%Y %H:%M'),labels:JSON.pretty_generate(m.count).gsub(':', ' =>')))
        end

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: message,
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )

      end
    end
  end
end
