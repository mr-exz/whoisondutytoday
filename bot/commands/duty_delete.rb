module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class DutyDelete

      DESCRIPTION = 'Will delete a duty.'.freeze
      EXAMPLE = 'Usage: `duty delete`'.freeze
      def self.call(client:, data:)
        duty = Duty.where(user_id: data.user, channel_id: data.channel).first
        if duty.blank?
          client.say(
            channel: data.channel,
            text: I18n.t('commands.duty.exist.error'),
            thread_ts: data.thread_ts || data.ts
          )
        else
          duty.delete
          client.say(
            channel: data.channel,
            text: I18n.t('commands.duty.deleted.text'),
            thread_ts: data.thread_ts || data.ts
          )
        end
      end
    end
  end
end
