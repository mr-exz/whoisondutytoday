require 'date'
require_relative 'commands/main'

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
    Commands.i_am_on_duty(data: data, client: client)
  end

  command 'who is on duty?' do |client, data|
    Commands.who_is_on_duty(data: data, client: client)
  end

  command 'checked' do |client, data|
    Commands.thread_checked(data: data, client: client)
  end

  command 'duty create' do |client, data, match|
    Commands.duty_create(client: client, data: data, match: match)
  end

  command 'create duty for user' do |client, data, match|
    Commands.duty_create_for_user(client: client, data: data, match: match)
  end

  command 'channel reminder enabled' do |client, data|
    Commands.channel_reminder_enabled(client: client, data: data)
  end

  command 'channel reminder disabled' do |client, data|
    Commands.channel_reminder_disabled(client: client, data: data)
  end

  command 'duty update' do |client, data, match|
    Commands.duty_update(client: client, data: data, match: match)
  end

  command 'duty delete' do |client, data, match|
    Commands.duty_delete(client: client, data: data, match: match)
  end

  command 'duty sync with opsgenie schedule' do |client, data, match|
    Commands.duty_sync_with_opsgenie(client: client, data: data, match: match)
  end

  command 'duty set opsgenie escalation' do |client, data, match|
    Commands.duty_set_opsgenie_escalation(client: client, data: data, match: match)
  end

  command 'answer set custom text' do |client, data, match|
    Commands.answer_set_custom_text(client: client, data: data, match: match)
  end

  command 'answer delete custom text' do |client, data, match|
    Commands.answer_delete_custom_text(client: client, data: data)
  end

  command 'answer enable hide reason' do |client, data|
    Commands.answer_enable_hide_reason(client: client, data: data)
  end

  command 'answer disable hide reason' do |client, data|
    Commands.answer_disable_hide_reason(client: client, data: data)
  end

  command 'action create' do |client, data, match|
    Commands.action_create(client: client, data: data, match: match)
  end

  command 'action delete' do |client, data, match|
    Commands.action_delete(client: client, data: data, match: match)
  end

  command(/.*/) do |client, data|
    Commands.unknown(client: client, data: data)
  end

  scan(/(.*)/) do |client, data, match|
    Commands.watch(client: client, data: data, match: match)
  end
end