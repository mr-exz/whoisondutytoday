module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class MyStatus
      def self.call(data:, client:, match:)
        status = match["expression"]
        if status.nil? || status == "work"
          User.where(slack_user_id: data.user).update_all(status: nil)
        else
          User.where(slack_user_id: data.user).update_all(status: status)
        end
        client.say(
          channel: data.channel,
          text: I18n.t("commands.user.status.configured.text", status: status),
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
