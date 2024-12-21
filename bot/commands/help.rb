module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class Help
      DESCRIPTION = 'Will show the available commands.'.freeze
      EXAMPLE = 'Command: `help`'.freeze

      def self.call(client:, data:)
        help_text = generate_help_text
        version_info = "Running version: #{ENV['VERSION']} | <https://github.com/mr-exz/whoisondutytoday|GitHub> | <https://github.com/mr-exz/whoisondutytoday/blob/master/CHANGELOG.md|Changelog>"

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: "Available commands:\n\n#{version_info}",
          attachments: help_text,
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end

      def self.generate_help_text
        commands = [
          Help,
          CallDutyPerson,
          MyStatus,
          IAmOnDuty,
          WhoIsOnDuty,
          Checked,
          DutyCreate,
          CreateDutyForUser,
          ChannelReminderEnabled,
          ChannelReminderDisabled,
          ChannelAutoAnswerEnable,
          ChannelAutoAnswerDisable,
          ChannelTagReporterInThreadEnable,
          ChannelTagReporterInThreadDisable,
          DutyUpdate,
          DutyDelete,
          DutySyncWithOpsgenieSchedule,
          DutySetOpsgenieEscalation,
          AnswerSetCustomText,
          AnswerDeleteCustomText,
          AnswerEnableHideReason,
          AnswerEnableHideReason,
          ActionCreate,
          ActionDelete,
          ThreadLabelsClean,
          ThreadLabels,
          ChannelLabelsStatistic,
          ChannelLabelsList,
          ChannelLabelsMerge,
          UserCommits,
        ]

        commands.map do |command|
          {
            fallback: command::DESCRIPTION.to_s,
            color: '#36a64f',
            fields: [
              {
                title: command::EXAMPLE,
                value: command::DESCRIPTION,
                short: false
              }
            ]
          }
        end

      end
    end
  end
end
