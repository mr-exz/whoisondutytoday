module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class AnswerDeleteCustomText
      DESCRIPTION = 'Will delete the custom text answer and use the default.'.freeze
      EXAMPLE = 'Usage: `answer delete custom text`'.freeze
      def self.call(client:, data:)
        Answer.where(channel_id: data.channel).delete_all

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t('commands.answer.deleted.text'),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
