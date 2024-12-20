module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelReminderDisabled

      DESCRIPTION = 'Will disable reminders for unanswered messages in the channel.'.freeze
      EXAMPLE = 'Usage: `channel reminder disabled`'.freeze
      def self.call(client:, data:)
        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(reminder_enabled: false)
        channel.save
        client.say(
          channel: data.channel,
          text: I18n.t('commands.channel.reminder.disabled.text'),
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
