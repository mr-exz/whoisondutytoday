require 'date'
require_relative 'commands'

class Router < SlackRubyBot::Bot
  SlackRubyBot::Client.logger.level = Logger::WARN

  command 'help' do |client, data|
    Commands.help(client: client, data: data)
  end

  command 'call duty person' do |client, data|
    Commands.call_of_duty(client: client, data: data)
  end

  command 'my status lunch' do |client, data|
    Commands.set_user_status(client: client, data: data, status: 'lunch')
  end

  command 'my status holidays' do |client, data|
    Commands.set_user_status(client: client, data: data, status: 'holidays')
  end

  command 'my status work' do |client, data|
    Commands.set_user_status(client: client, data: data, status: 'work')
  end

  command 'i am on duty' do |client, data|
    Commands.i_am_on_duty(data: data, client: client)
  end

  command 'who is on duty?' do |client, data|
    Commands.who_is_on_duty(data: data, client: client)
  end

  command 'duty create' do |client, data, match|
    Commands.duty_create(client: client, data: data, match: match)
  end

  command 'create duty for user' do |client, data, match|
    Commands.duty_create_for_user(client: client, data: data, match: match)
  end

  command 'channel reminder enabled' do |client, data, match|
    Commands.channel_reminder_enabled(client: client, data: data, match: match)
  end

  command 'channel reminder disabled' do |client, data, match|
    Commands.channel_reminder_disabled(client: client, data: data, match: match)
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
    Commands.answer_delete_custom_text(client: client, data: data, match: match)
  end

  command 'answer enable hide reason' do |client, data|
    Commands.answer_enable_hide_reason(client: client, data: data)
  end

  command 'answer disable hide reason' do |client, data|
    Commands.answer_disable_hide_reason(client: client, data: data)
  end

  command(/.*/) do |client, data|
    Commands.unknown(client: client, data: data)
  end

  scan(/(.*)/) do |client, data, match|
    Commands.watch(client: client, data: data, match: match)
  end
end