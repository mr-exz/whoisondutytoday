module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class IAmOnDuty
      DESCRIPTION = 'Will set you as the duty person in the channel.'.freeze
      EXAMPLE = '`i am on duty`'.freeze
      def self.call(client:, data:)
        Duty.where(channel_id: data.channel).where(user_id: data.user).update_all(enabled: true)
        Duty.where(channel_id: data.channel).where.not(user_id: data.user).update_all(enabled: false)
        client.say(
          channel: data.channel,
          text: I18n.t('commands.duty.enabled.text'),
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
