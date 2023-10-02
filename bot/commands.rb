require_relative 'notify'
require 'json'
require_relative 'message_processor'

class Commands

  def self.help(client:, data:)
    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.help.text', version: Whoisondutytoday::Application::VERSION),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end

  def self.duty_sync_with_opsgenie(client:, data:, match:)
    opsgenie_schedule_name = match['expression']
    Duty.where(channel_id: data.channel).update_all(opsgenie_schedule_name: opsgenie_schedule_name)

    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.opsgenie-schedule-name.text'),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end

  def self.duty_set_opsgenie_escalation(client:, data:, match:)
    opsgenie_escalation_name = match['expression']
    Duty.where(channel_id: data.channel).update_all(opsgenie_escalation_name: opsgenie_escalation_name)

    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.opsgenie-escalation-name.text'),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end

  def self.action_create(client:, data:, match:)
    action = Action.new(
      problem: match['expression'][/problem:(.*) action:/, 1],
      action: match['expression'][/ action:(.*)$/, 1],
      channel: data.channel
    )

    if action.save
      client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t('commands.action.created.text'),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
      )
    else
      client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t('commands.action.failed.text'),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
      )
    end

  end

  def self.action_delete(client:, data:, match:)
    Action.where(
      problem: match['expression'][/problem:(.*)/, 1],
      channel: data.channel
    ).delete_all

    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.action.deleted.text'),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end

  def self.answer_set_custom_text(client:, data:, match:)
    custom_text = match['expression']
    Answer.where(channel_id: data.channel).delete_all
    answer = Answer.new
    answer.body = custom_text
    answer.channel_id = data.channel

    if answer.save

      client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t('commands.answer.created.text'),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
      )

      client.web_client.chat_postMessage(
        channel: data.channel,
        text: custom_text,
        thread_ts: data.thread_ts || data.ts,
        as_user: true
      )
    else
      client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t('commands.answer.failed.text'),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
      )
    end

  end

  def self.answer_delete_custom_text(client:, data:)
    Answer.where(channel_id: data.channel).delete_all

    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.answer.deleted.text'),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end

  def self.duty_create(client:, data:, match:)
    message_processor = MessageProcessor.new
    slack_web_client = Slack::Web::Client.new
    begin
      channel_info = slack_web_client.channels_info(channel: data.channel)
    rescue
      channel_info = Hash.new
      channel_info['channel'] = Hash.new
      channel_info['channel']['id'] = data.channel
      channel_info['channel']['name'] = nil
      channel_info['channel']['value'] = nil
    end

    channel = Channel.where(slack_channel_id: data.channel).first
    if channel.blank?
      channel = Channel.new
      channel.slack_channel_id = channel_info['channel']['id']
      channel.name = channel_info['channel']['name']
      channel.description = channel_info['channel']['value']
      channel.save
    end

    message_processor.collectUserInfo(data: data)
    user = User.where(slack_user_id: data.user).first

    duty = Duty.where(user_id: data.user, channel_id: data.channel).first
    if duty.blank?
      duty = Duty.new
      duty.duty_from = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match['expression'][/from (\d+:\d+) /, 1].to_time)
      duty.duty_to = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match['expression'][/.* to (\d+:\d+)$/, 1].to_time)
      duty.channel_id = data.channel
      duty.user_id = user.id
      duty.enabled = true
      duty.save
      client.say(
        channel: data.channel,
        text: I18n.t('commands.duty.created.text', fH: duty.duty_from.hour, fM: duty.duty_from.min, tH: duty.duty_to.hour, tM: duty.duty_to.min, status: duty.enabled),
        thread_ts: data.thread_ts || data.ts
      )
      i_am_on_duty(data: data, client: client)
    else
      client.say(
        channel: data.channel,
        text: I18n.t('commands.duty.exist.text', fH: duty.duty_from.hour, fM: duty.duty_from.min, tH: duty.duty_to.hour, tM: duty.duty_to.min, status: duty.enabled),
        thread_ts: data.thread_ts || data.ts
      )
    end
  end

  def self.duty_create_for_user(client:, data:, match:)
    message_processor = MessageProcessor.new
    slack_web_client = Slack::Web::Client.new

    begin
      channel_info = slack_web_client.channels_info(channel: data.channel)
    rescue
      channel_info = Hash.new
      channel_info['channel'] = Hash.new
      channel_info['channel']['id'] = data.channel
      channel_info['channel']['name'] = nil
      channel_info['channel']['value'] = nil
    end

    channel = Channel.where(slack_channel_id: data.channel).first
    if channel.blank?
      channel = Channel.new
      channel.slack_channel_id = channel_info['channel']['id']
      channel.name = channel_info['channel']['name']
      channel.description = channel_info['channel']['value']
      channel.save
    end

    user_name = match['expression'][/<@(.+)>/, 1]
    message_processor.collectUserInfoBySlackUserId(user_name)
    user = User.where(slack_user_id: user_name).first

    duty = Duty.where(user_id: user_name, channel_id: data.channel).first
    if duty.blank?
      duty = Duty.new
      duty.duty_from = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match['expression'][/from (\d+:\d+) /, 1].to_time)
      duty.duty_to = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match['expression'][/.* to (\d+:\d+)$/, 1].to_time)
      duty.channel_id = data.channel
      duty.user_id = user.id
      duty.enabled = true
      duty.save
      client.say(
        channel: data.channel,
        text: I18n.t('commands.duty.created.text', fH: duty.duty_from.hour, fM: duty.duty_from.min, tH: duty.duty_to.hour, tM: duty.duty_to.min, status: duty.enabled),
        thread_ts: data.thread_ts || data.ts
      )
      set_user_on_duty(data: data, client: client, slack_user_id: user_name)
    else
      client.say(
        channel: data.channel,
        text: I18n.t('commands.duty.exist.text', fH: duty.duty_from.hour, fM: duty.duty_from.min, tH: duty.duty_to.hour, tM: duty.duty_to.min, status: duty.enabled),
        thread_ts: data.thread_ts || data.ts
      )
    end
  end

  def self.channel_reminder_enabled(client:, data:)
    channel = Channel.where(slack_channel_id: data.channel).first
    channel.reminder_enabled = true
    channel.save
    client.say(
      channel: data.channel,
      text: I18n.t('commands.channel.reminder.enabled.text'),
      thread_ts: data.thread_ts || data.ts
    )
  end

  def self.channel_reminder_disabled(client:, data:)
    channel = Channel.where(slack_channel_id: data.channel).first
    channel.reminder_enabled = false
    channel.save
    client.say(
      channel: data.channel,
      text: I18n.t('commands.channel.reminder.disabled.text'),
      thread_ts: data.thread_ts || data.ts
    )
  end

  def self.duty_update(client:, data:, match:)
    duty = Duty.where(user_id: data.user, channel_id: data.channel).first

    if duty.blank?
      client.say(
        channel: data.channel,
        text: I18n.t('commands.duty.exist.error'),
        thread_ts: data.thread_ts || data.ts
      )
    else
      user = User.where(slack_user_id: data.user).first
      duty.duty_from = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match['expression'][/from (\d+:\d+) /, 1].to_time)
      duty.duty_to = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match['expression'][/.* to (\d+:\d+)$/, 1].to_time)
      duty.channel_id = data.channel
      duty.user_id = user.id
      duty.enabled = true
      duty.save
      client.say(
        channel: data.channel,
        text: I18n.t('commands.duty.updated.text', fH: duty.duty_from.hour, fM: duty.duty_from.min, tH: duty.duty_to.hour, tM: duty.duty_to.min, status: duty.enabled),
        thread_ts: data.thread_ts || data.ts
      )
      i_am_on_duty(data: data, client: client)
    end
  end

  def self.duty_delete(client:, data:, match:)
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

  def self.i_am_on_duty(data:, client:)
    Duty.where(channel_id: data.channel).where(user_id: data.user).update_all(enabled: true)
    Duty.where(channel_id: data.channel).where.not(user_id: data.user).update_all(enabled: false)
    client.say(
      channel: data.channel,
      text: I18n.t('commands.duty.enabled.text'),
      thread_ts: data.thread_ts || data.ts
    )
  end

  def self.set_user_on_duty(data:, client:, slack_user_id:)
    Duty.where(channel_id: data.channel).where(user_id: slack_user_id).update_all(enabled: true)
    Duty.where(channel_id: data.channel).where.not(user_id: slack_user_id).update_all(enabled: false)
    client.say(
      channel: data.channel,
      text: I18n.t('commands.duty.enabled-for-user.text', name: slack_user_id),
      thread_ts: data.thread_ts || data.ts
    )
  end

  def self.who_is_on_duty(data:, client:)
    duty = Duty.where(channel_id: data.channel).where(enabled: true).take!
    client.say(
      channel: data.channel,
      text: I18n.t('commands.user.status.enabled.duty',
                   user: duty.user.real_name,
                   duty_from: duty.duty_from.strftime('%H:%M').to_s,
                   duty_to: duty.duty_to.strftime('%H:%M').to_s
      ),
      thread_ts: data.thread_ts || data.ts
    )
  end

  def self.thread_checked(data:, client:)
    message_processor = MessageProcessor.new
    message_processor.disable_message_from_remind(data: data)
    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.thread.checked'),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end

  def self.reply_in_not_working_time (client, reason, data, answer)

    if answer.nil?
      text = I18n.t('reply.non-working-time.text', name: client.self.name)
    else
      text = answer.body
      if answer.hide_reason == 1
        reason = ""
      end
    end

    client.web_client.chat_postMessage(
      text: '%s' % reason,
      channel: data.channel,
      attachments: [
        {
          fallback: I18n.t('reply.non-working-time.subject'),
          text: text,
          color: '#3AA3E3',
          attachment_type: 'default'
        }
      ],
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
    message_processor = MessageProcessor.new
    message_processor.save_message(data: data)
  end

  def self.reply_to_known_problem (client:, problem:, data:, action:)
    client.web_client.chat_postMessage(
      text: '%s' % I18n.t('reply.known-problem.subject'),
      channel: data.channel,
      attachments: [
        {
          text: "Problem: %s \nAction: %s" % [problem, action],
          color: '#3AA3E3',
          attachment_type: 'default'
        }
      ],
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
    message_processor = MessageProcessor.new
    message_processor.save_message(data: data)
  end

  def self.watch(client:, data:, match:)
    message_processor = MessageProcessor.new
    time = DateTime.strptime(data.ts, '%s')

    # skip processing events and data without client_msg_id
    return if data.respond_to?(:client_msg_id) == false and data.respond_to?(:files) == false

    begin
      channel = Channel.where(slack_channel_id: data.channel).first
      return if channel.nil?
      duty = Duty.where(channel_id: data.channel, enabled: true).first
      answer = Answer.where(channel_id: data.channel).first

      # store messages where reminder needed
      if channel.reminder_enabled == true
        message_processor.save_message_for_reminder(data: data) if data.respond_to?(:thread_ts) == false and data.user != duty.user.slack_user_id
        message_processor.disable_message_from_remind(data: data) if data.user == duty.user.slack_user_id and data.respond_to?(:thread_ts) == true
      end

      # don't reply on duty person messages
      #return if data.user == duty.user.slack_user_id

      # Answer if it is known problem
      if data != nil and match != nil
        Action.where(channel: data.channel).each do |action|
          Regexp.new(/#{action.problem}/i).match(data.text) do |_|
            reply_to_known_problem(client: client, problem: action.problem, data: data, action: action.action)
          end
        end
      end

      # check if message written in channel
      if data.respond_to?(:thread_ts) == false
        message_processor.collectUserInfo(data: data)
        reason = self.answer(time, duty)
        reply_in_not_working_time(client, reason, data, answer) unless reason.nil?
        return
      end

      # check if message written in thread without answer from bot
      message = Message.where('ts=? OR thread_ts=?', data.thread_ts, data.thread_ts).where(reply_counter: 1)
      if message.blank?
        reason = self.answer(time, duty)
        reply_in_not_working_time(client, reason, data, answer) unless reason.nil?
      end
    rescue StandardError => e
      print e
    end
  end

  def self.answer(time, duty)
    reason = nil

    if time.utc.strftime('%H%M%S%N') < duty.duty_from.utc.strftime('%H%M%S%N') or time.utc.strftime('%H%M%S%N') > duty.duty_to.utc.strftime('%H%M%S%N')
      from_time = (duty.duty_from.utc).strftime('%H:%M').to_s
      to_time = (duty.duty_to.utc).strftime('%H:%M').to_s
      current_time = (time.utc).strftime('%H:%M').to_s
      reason = I18n.t('reply.reason.non-working-hours.text', fT: from_time, tT: to_time, cT: current_time)
    end

    unless duty.duty_days.split(',').include?(time.utc.strftime('%u'))
      reason = I18n.t('reply.reason.non-working-day.text')
    end

    unless duty.user.status.nil?
      reason = I18n.t('commands.user.status.enabled.text', status: duty.user.status)
    end

    reason
  end

  def self.unknown(client:, data:)
    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.unknown.text', name: client.self.name),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end

  def self.answer_enable_hide_reason(client:, data:)
    if Answer.where(channel_id: data.channel).update_all(hide_reason: true)
      client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t('commands.enable.hide_reason.text', name: client.self.name),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
      )
    else
      client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t('commands.enable.hide_reason.failed.text', name: client.self.name),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
      )
    end
  end

  def self.answer_disable_hide_reason(client:, data:)
    Answer.where(channel_id: data.channel).update_all(hide_reason: false)
    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.disable.hide_reason.text', name: client.self.name),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end

end