module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class AnswerDisableHideReason
      def self.call(client:, data:)
        Answer.where(channel_id: data.channel).update_all(hide_reason: false)
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t("commands.disable.hide_reason.text", name: client.self.name),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
