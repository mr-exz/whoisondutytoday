module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ThreadLabelsClean
      def self.call(client:, data:, match:)
        SlackThread.find_by(thread_ts: data.thread_ts).destroy
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t("commands.thread.labels.cleaned"),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
