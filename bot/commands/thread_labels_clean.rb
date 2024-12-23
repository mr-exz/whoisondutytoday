module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ThreadLabelsClean
      DESCRIPTION = 'Will remove all labels from the thread where you write it.'.freeze
      EXAMPLE = '`thread labels clean`'.freeze
      def self.call(client:, data:, match:)
        SlackThread.find_by(thread_ts: data.thread_ts).destroy
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t('commands.thread.labels.cleaned'),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
