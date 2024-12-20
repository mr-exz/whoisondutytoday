module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class Help

      DESCRIPTION = 'Will show the available commands.'.freeze
      EXAMPLE = 'Usage: `help`'.freeze
      def self.call(client:, data:)
        help_text = generate_help_text
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: help_text,
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

        help_text = "Here are the available commands:\n\n"
        commands.each do |command|
          help_text += "* #{command::DESCRIPTION}\n"
          help_text += "  #{command::EXAMPLE}\n\n"
        end

        help_text
      end
    end
  end
end
