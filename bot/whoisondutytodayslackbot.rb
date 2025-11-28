require 'date'
require 'json'

# Commands
require_relative 'slacksocket'
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

  command 'channel prompt set' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelPromptSet.call(client: client, data: data, match: match)
  end

  command 'channel prompt get' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelPromptGet.call(client: client, data: data, match: match)
  end

  command 'channel prompt delete' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ChannelPromptDelete.call(client: client, data: data, match: match)
  end

  command 'git commits' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::UserCommits.call(client: client, data: data, match: match)
  end

  command 'claude' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ClaudePrompt.call(client: client, data: data, match: match)
  end

  command 'claude-plugins sync' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::ClaudePluginSync.call(client: client, data: data)
  end

  command 'prepare summary' do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::PrepareSummary.call(client: client, data: data)
  end

  command 'create jira task' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::JiraCreateTask.call(client: client, data: data, match: match)
  end

  command 'configure jira issue defaults' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::ConfigureJiraIssueDefaults.call(client: client, data: data, match: match)
  end

  command 'take a look' do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::TakeALook.call(client: client, data: data, match: match)
  end

  command(/.*/) do |client, data|
    WhoIsOnDutyTodaySlackBotModule::Commands::Unknown.call(client: client, data: data)
  end

  scan(/(.*)/) do |client, data, match|
    WhoIsOnDutyTodaySlackBotModule::Commands::Other.call(client: client, data: data, match: match)
  end

  def self.client
    @client ||= SlackSocket::Client.new
  end

  def self.run
    client.connect
  end

  def self.command_classes
    SlackRubyBot::Commands::Base.command_classes
  end

  def self.built_in_command_classes
    command_classes.select do |k|
      k.name&.starts_with?('SlackRubyBot::Commands::') && k != SlackRubyBot::Commands::Unknown
    end
  end

  def self.prepare!(data)
    data.text = data.text.strip if data.text
  end
  def self.child_command_classes
    command_classes.reject do |k|
      k.name&.starts_with?('SlackRubyBot::Commands::')
    end
  end

  def self.process_event(client, data)
    event = data['payload']['event']

    # Skip app_mention events - we only process message events
    # Slack sends both app_mention and message for bot mentions, we only need message
    return if event['type'] == 'app_mention'

    return if !client.allow_message_loops? && client.message_to_self?(data)
    return if !client.allow_bot_messages? && client.bot_message?(data)

    # For messages from bots/automation, only process if they mention the bot
    if is_from_bot?(event)
      unless message_mentions_bot?(event, client)
        log_ignored_message(event)
        return
      end
    end

    #p data
    prepare!(data)
    child_command_classes.each do |command_class|
      command_class.invoke(client, convert_event_to_simple_format(data))
    end
  end

  def self.is_from_bot?(event)
    event.key?('bot_id') || event.key?('app_id')
  end

  def self.message_mentions_bot?(event, client)
    text = event['text'] || ''
    bot_mention = "<@#{client.self.id}>"
    text.include?(bot_mention)
  end

  def self.log_ignored_message(event)
    logger = Logger.new(STDOUT)
    bot_name = event['bot_profile']&.dig('name') || event['username'] || 'Unknown Bot'
    logger.info({
      ignored_message: true,
      bot_name: bot_name,
      channel: event['channel'],
      ts: event['ts']
    }.to_json)
  end

  def self.convert_event_to_simple_format(event)
    event['payload']['event']
  end
end