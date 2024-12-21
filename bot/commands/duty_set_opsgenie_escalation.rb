module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class DutySetOpsgenieEscalation
      DESCRIPTION = 'Will configure all duties in the channel with the escalation name from Opsgenie.'.freeze
      EXAMPLE = 'Usage: `duty set opsgenie escalation My_Team_Escalation`'.freeze
      def self.call(client:, data:, match:)
        opsgenie_escalation_name = match['expression']
        Duty.where(channel_id: data.channel).update_all(opsgenie_escalation_name: opsgenie_escalation_name)

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t('commands.opsgenie-escalation-name.text'),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
