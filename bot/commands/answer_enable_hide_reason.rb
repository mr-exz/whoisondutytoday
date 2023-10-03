module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class AnswerEnableHideReason
      def self.call(client:,data:)
        if Answer.where(channel_id: data.channel).update_all(hide_reason: true)
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.enable.hide_reason.text', name: client.self.name),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.enable.hide_reason.failed.text', name: client.self.name),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end