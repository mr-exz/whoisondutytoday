module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class WhoIsOnDuty
      DESCRIPTION = 'Will display the name of the duty person.'.freeze
      EXAMPLE = 'Usage: `who is on duty?`'.freeze
      def self.call(client:, data:)
        duty = Duty.where(channel_id: data.channel).where(enabled: true).take!
        client.say(
          channel: data.channel,
          text: I18n.t('commands.user.status.enabled.duty',
            user: duty.user.real_name,
            duty_from: duty.duty_from.strftime('%H:%M').to_s,
            duty_to: duty.duty_to.strftime('%H:%M').to_s),
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
