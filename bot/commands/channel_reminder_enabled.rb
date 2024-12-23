module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelReminderEnabled

      DESCRIPTION = 'Will enable reminders for unanswered messages in the channel. Bot will send links to threads without responses each 15 min to duty person in direct message'.freeze
      EXAMPLE = '`channel reminder enabled`'.freeze
        def self.call(client:, data:)
        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.update(reminder_enabled: true)
        channel.save
        client.say(
          channel: data.channel,
          text: I18n.t('commands.channel.reminder.enabled.text'),
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
