module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class DutySyncWithOpsgenieSchedule
      DESCRIPTION = 'Duty person will be taken from Opsgenie when his shift comes, rotation happen each 5 min.'.freeze
      EXAMPLE = '`duty sync with opsgenie schedule <schedule name>` example: `duty sync with opsgenie schedule My_Team_Schedule`'.freeze
      def self.call(client:, data:, match:)
        opsgenie_schedule_name = match['expression']
        Duty.where(channel_id: data.channel).update_all(opsgenie_schedule_name: opsgenie_schedule_name)

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t('commands.opsgenie-schedule-name.text'),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
