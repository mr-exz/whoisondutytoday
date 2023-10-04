module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelReminderEnabled
      def self.call(client:, data:)
        channel = Channel.where(slack_channel_id: data.channel).first
        channel.reminder_enabled = true
        channel.save
        client.say(
          channel: data.channel,
          text: I18n.t("commands.channel.reminder.enabled.text"),
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
