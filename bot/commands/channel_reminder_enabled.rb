module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelReminderEnabled
      def self.call(client:, data:)
        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(reminder_enabled: true)
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
