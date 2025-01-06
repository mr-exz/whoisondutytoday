require 'date'
require 'json'

# Commands
require_relative 'commands/main'

# Libraries
require_relative '../lib/opsgenie/notify_opsgenie'
require_relative '../lib/message_processor/message_processor'


class WhoIsOnDutyTodaySlackBot < SlackRubyBot::Bot
  SlackRubyBot::Client.logger.level = Logger::WARN

  command 'help' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::Help.call(client: client, data: data)
  end

  command 'call duty person' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::CallDutyPerson.call(client: client, data: data)
  end

  command 'my status' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::MyStatus.call(client: client, data: data, match: match)
  end

  command 'i am on duty' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::IAmOnDuty.call(client: client, data: data)
  end

  command 'who is on duty?' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::WhoIsOnDuty.call(client: client, data: data)
  end

  command 'checked' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::Checked.call(client: client, data: data)
  end

  command 'duty create for' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::DutyCreate.call(client: client, data: data, match: match)
  end

  command 'duty delete for' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::DutyDelete.call(client: client, data: data, match: match)
  end

  command 'channel reminder_enabled' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelReminder.call(client: client, data: data, match: match)
  end

  command 'channel auto_answer_enabled' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelAutoAnswer.call(client: client, data: data, match: match)
  end

  command 'channel tag_reporter_enabled' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelTagReporterInThread.call(client: client, data: data, match: match)
  end

  command 'duty sync with opsgenie schedule' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::DutySyncWithOpsgenieSchedule.call(client: client, data: data, match: match)
  end

  command 'duty set opsgenie escalation' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::DutySetOpsgenieEscalation.call(client: client, data: data, match: match)
  end

  command 'answer set custom text' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::AnswerSetCustomText.call(client: client, data: data, match: match)
  end

  command 'answer delete custom text' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::AnswerDeleteCustomText.call(client: client, data: data)
  end

  command 'answer enable hide reason' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::AnswerEnableHideReason.call(client: client, data: data)
  end

  command 'answer disable hide reason' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::AnswerDisableHideReason.call(client: client, data: data)
  end

  command 'action create' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ActionCreate.call(client: client, data: data, match: match)
  end

  command 'action delete' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ActionDelete.call(client: client, data: data, match: match)
  end

  command 'action show problems' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::ActionShowProblems.call(client: client, data: data)
  end

  command 'action show action for' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ActionShowAction.call(client: client, data: data, match: match)
  end

  command 'thread labels clean' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ThreadLabelsClean.call(client: client, data: data, match: match)
  end

  command 'thread labels' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ThreadLabels.call(client: client, data: data, match: match)
  end

  command 'channel labels statistic' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelLabelsStatistic.call(client: client, data: data, match: match)
  end

  command 'channel labels list' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelLabelsList.call(client: client, data: data, match: match)
  end

  command 'channel labels merge' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelLabelsMerge.call(client: client, data: data, match: match)
  end

  command 'git commits' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::UserCommits.call(client: client, data: data, match: match)
  end

  command(/.*/) do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::Unknown.call(client: client, data: data)
  end

  scan(/(.*)/) do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::Other.call(client: client, data: data, match: match)
  end
end

