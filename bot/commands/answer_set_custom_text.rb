module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class AnswerSetCustomText
      def self.call(client:,data:,match:)
        custom_text = match['expression']
        Answer.where(channel_id: data.channel).delete_all
        answer = Answer.new
        answer.body = custom_text
        answer.channel_id = data.channel

        if answer.save

          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.answer.created.text'),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )

          client.web_client.chat_postMessage(
            channel: data.channel,
            text: custom_text,
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.answer.failed.text'),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end