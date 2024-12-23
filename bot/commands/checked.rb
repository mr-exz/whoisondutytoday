module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class Checked
      DESCRIPTION = 'Will mark the thread as checked.'.freeze
      EXAMPLE = '`checked`'.freeze
      def self.call(client:, data:)
        message_processor = MessageProcessor.new
        message_processor.disable_message_from_remind(data: data)
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t('commands.thread.checked'),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
