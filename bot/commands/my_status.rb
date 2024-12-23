module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class MyStatus
      DESCRIPTION = <<~DESC
        Will set any status when you cannot provide support in the channels where you are on duty. Bot will reply instead of you.
        `my status work` - Bot will stop telling your status. Use it when you come back.
      DESC
      EXAMPLE = '`my status <some words about status>` example: `my status on lunch`'.freeze
      def self.call(data:, client:, match:)
        status = match['expression']
        if status.nil? || status == 'work'
          User.where(slack_user_id: data.user).update_all(status: nil)
        else
          User.where(slack_user_id: data.user).update_all(status: status)
        end
        client.say(
          channel: data.channel,
          text: I18n.t('commands.user.status.configured.text', status: status),
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
