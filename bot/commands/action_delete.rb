module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ActionDelete
      DESCRIPTION = 'Will delete the answer from the bot for this keyword.'.freeze
      EXAMPLE = 'Usage: `action delete problem:NEWERROR`'.freeze
      def self.call(client:, data:, match:)
        Action.where(
          problem: match['expression'][/problem:(.*)/, 1],
          channel: data.channel
        ).delete_all

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t('commands.action.deleted.text'),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
