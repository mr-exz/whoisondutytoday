module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ActionCreate
      DESCRIPTION = 'Will create an answer from the bot for this keyword problem.'.freeze
      EXAMPLE = 'Usage: `action create problem:NEWERROR action:What to do with this error`'.freeze
      def self.call(client:, data:, match:)
        action = Action.new(
          problem: match['expression'][/problem:(.*) action:/, 1],
          action: match['expression'][/ action:(.*)$/, 1],
          channel: data.channel
        )

        if action.save
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.action.created.text'),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.action.failed.text'),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end
