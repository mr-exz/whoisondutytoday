module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class AnswerSetCustomText
      DESCRIPTION = 'Will configure default answer in channel. type:non_working_time/working_time'.freeze
      EXAMPLE = '`answer set custom text type:<time type> text:<custom text>` example: `bot answer set custom text type:non_working_time text:This is the custom text for non working hours.`'.freeze
      def self.call(client:, data:, match:)
        expression = match['expression']

        if expression =~ /type:(\w+)\s+text:(.+)/m
          answer_type = ::Regexp.last_match(1)
          custom_text = ::Regexp.last_match(2).strip
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.answer.invalid_format.text'),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
          return
        end

        Answer.where(channel_id: data.channel, answer_type: answer_type).delete_all
        answer = Answer.new
        answer.body = custom_text
        answer.channel_id = data.channel
        answer.answer_type = answer_type

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
      rescue StandardError => e
        client.say(
          channel: data.channel,
          text: e,
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end