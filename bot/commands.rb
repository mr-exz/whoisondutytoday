require_relative 'notify'
require 'json'
require_relative 'message_processor'

class Commands

  def self.help(client:,data:)
    client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t("commands.help.text", version: Whoisondutytoday::Application::VERSION),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
    )
  end

  def self.duty_sync_with_opsgenie(client:, data:, match:)
    opsgenie_schedule_name = match['expression']
    Duty.where(channel_id: data.channel).update_all(opsgenie_schedule_name: opsgenie_schedule_name)

    client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t("commands.opsgenie-schedule-name.text", version: Whoisondutytoday::Application::VERSION),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
    )
  end

  def self.call_of_duty(client:, data:)
    duty = Duty.where(channel_id: data.channel).where(enabled: true).take!
    slack_web_client = Slack::Web::Client.new
    client_info = slack_web_client.users_info(user: data.user)

    notification = NotifyOpsgenie.new

    recipient = {}
    if !duty.opsgenie_schedule_name.nil?
      recipient['name'] = duty.opsgenie_schedule_name
      recipient['type'] = 'schedule'
    else
      recipient['name'] = duty.user.contacts
      recipient['type'] = 'user'
    end

    response = notification.send(recipient, client_info)

    json_response = JSON.parse(response.body)

    if !json_response["result"].nil?
      reply = I18n.t("reply.opsgenie.text")
    elsif !json_response["message"].nil?
      reply = I18n.t("reply.opsgenie.error",message: json_response["message"])
    end

    client.say(
        channel: data.channel,
        text: reply,
        thread_ts: data.thread_ts || data.ts
    )
  end

  def self.duty_create(client:,data:,match:)
    message_processor = MessageProcessor.new
    slack_web_client = Slack::Web::Client.new
    user_info = slack_web_client.users_info(user: data.user)
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
          text: I18n.t("commands.duty.created.text", fH: duty.duty_from.hour,fM: duty.duty_from.min,tH: duty.duty_to.hour,tM: duty.duty_to.min,status: duty.enabled),
          thread_ts: data.thread_ts || data.ts
      )
      i_am_on_duty(data: data,client: client)
    else
      client.say(
          channel: data.channel,
          text: I18n.t("commands.duty.exist.text", fH: duty.duty_from.hour,fM: duty.duty_from.min,tH: duty.duty_to.hour,tM: duty.duty_to.min,status: duty.enabled),
          thread_ts: data.thread_ts || data.ts
      )
    end
  end

  def self.duty_update(client:, data:, match:)
    duty = Duty.where(user_id: data.user, channel_id: data.channel).first

    if duty.blank?
      client.say(
          channel: data.channel,
          text: I18n.t("commands.duty.exist.error"),
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
          text: I18n.t("commands.duty.exist.error",fH: duty.duty_from.hour,fM: duty.duty_from.min,tH: duty.duty_to.hour,tM: duty.duty_to.min,status: duty.enabled),
          thread_ts: data.thread_ts || data.ts
      )
      i_am_on_duty(data: data,client: client)
    end
  end

  def self.duty_delete(client:,data:,match:)
    duty = Duty.where(user_id: data.user, channel_id: data.channel).first

    if duty.blank?
      client.say(
          channel: data.channel,
          text: I18n.t("commands.duty.exist.error"),
          thread_ts: data.thread_ts || data.ts
      )
    else
      duty.delete
      client.say(
          channel: data.channel,
          text: I18n.t("commands.duty.deleted.text"),
          thread_ts: data.thread_ts || data.ts
      )
    end
  end

  def self.i_am_on_duty(data:,client:)
    Duty.where(channel_id: data.channel).where(user_id: data.user).update_all(enabled: true)
    Duty.where(channel_id: data.channel).where.not(user_id: data.user).update_all(enabled: false)
    client.say(
        channel: data.channel,
        text: I18n.t("commands.duty.enabled.text"),
        thread_ts: data.thread_ts || data.ts
    )
  end

  def self.set_user_on_duty(data:, client:, user:)
    Duty.where(channel_id: data.channel).where(user_id: user.slack_user_id).update_all(enabled: true)
    Duty.where(channel_id: data.channel).where.not(user_id: user.slack_user_id).update_all(enabled: false)
  end

  def self.set_user_status(data:, client:, status:)
    User.where(slack_user_id: data.user).update_all(status: status)
    client.say(
        channel: data.channel,
        text:  I18n.t("commands.user.status.configured.text",status: status),
        thread_ts: data.thread_ts || data.ts
    )
  end

  def self.who_is_on_duty(data:, client:)
    duty = Duty.where(channel_id: data.channel).where(enabled: true).take!
    client.say(
        channel: data.channel,
        text: I18n.t("commands.user.status.enabled.duty",user: duty.user.real_name),
        thread_ts: data.thread_ts || data.ts
    )
  end

  def self.reply_in_not_working_time (client, reason, duty, time, data)
    client.web_client.chat_postMessage(
        text: '%s' % reason,
        channel: data.channel,
        as_user: true,
        attachments: [
            {
                fallback: I18n.t("reply.non-working-time.subject"),
                text: I18n.t("reply.non-working-time.text",name: client.self.name),
                color: '#3AA3E3',
                attachment_type: 'default'
                # actions: [
                #     {
                #         name: "decision",
                #         text: "No",
                #         type: "button",
                #         value: "no"
                #     },
                #     {
                #         name: "decision",
                #         text: "Yes",
                #         type: "button",
                #         value: "yes"
                #     }
                # ]
            }
        ],
        thread_ts: data.thread_ts || data.ts,
        as_user: true
    )

    message = Message.new
    message.message_id = data.client_msg_id
    message.ts = data.ts
    message.thread_ts = data.thread_ts
    message.event_ts = data.event_ts
    message.reply_counter = 1
    message.save
  end

  def self.watch(client:, data:)
    message_processor = MessageProcessor.new
    time = DateTime.strptime(data.ts, '%s')

    if data.thread_ts.nil?
      message_processor.collectUserInfo(data: data)
      user = User.where(slack_user_id: data.user).first
      duty = Duty.where(channel_id: data.channel, enabled: true).first

      dutys = Duty.where(channel_id: data.channel).first
      if !dutys.opsgenie_schedule_name.nil?
        notification = NotifyOpsgenie.new
        json_response = JSON.parse(notification.GetOnCall(schedule_name: dutys.opsgenie_schedule_name).body)
        users = User.where(contacts: json_response['data']['onCallRecipients'][0]).first
        set_user_on_duty(data: data, client: client, user: users) if duty.user.slack_user_id != users.slack_user_id
      end

      return if data.user == duty.user.slack_user_id

      if time.utc.strftime('%H%M%S%N') < duty.duty_from.utc.strftime('%H%M%S%N') or time.utc.strftime('%H%M%S%N') > duty.duty_to.utc.strftime('%H%M%S%N')
        from_time = (duty.duty_from.utc + user.tz_offset).strftime('%H:%M').to_s
        to_time = (duty.duty_to.utc + user.tz_offset).strftime('%H:%M').to_s
        current_time = (time.utc + user.tz_offset).strftime('%H:%M').to_s
        reason = I18n.t("reply.reason.non-working-hours.text",fT: from_time,tT: to_time,cT: current_time)
      end

      if !duty.duty_days.split(',').include?(time.utc.strftime('%u'))
        reason = I18n.t("reply.reason.non-working-day.text")
      end

      if duty.user.status == 'lunch'
        reason = I18n.t("commands.user.status.enabled.lunch")
      end

      if duty.user.status == 'holidays'
        reason = I18n.t("commands.user.status.enabled.holidays")
      end

      reply_in_not_working_time(client, reason, duty, time, data) if !reason.nil?
    else
      message = Message.find_by(ts: data.thread_ts)
      if data.thread_ts != message.ts
        duty = Duty.where(channel_id: data.channel, enabled: true).first

        if time.utc.strftime('%H%M%S%N') < duty.duty_from.utc.strftime('%H%M%S%N') or time.utc.strftime('%H%M%S%N') > duty.duty_to.utc.strftime('%H%M%S%N')
          reason = I18n.t("reply.reason.non-working-hours.text",fT: duty.duty_from.utc.strftime('%H:%M').to_s,tT: duty.duty_to.utc.strftime('%H:%M').to_s,cT: time.utc.strftime('%H:%M').to_s)
        end

        if !duty.duty_days.split(',').include?(time.utc.strftime('%u'))
          reason = I18n.t("reply.reason.non-working-day.text")
        end

        if duty.user.status == 'lunch'
          reason = I18n.t("commands.user.status.enabled.lunch")
        end

        if duty.user.status == 'holidays'
          reason = I18n.t("commands.user.status.enabled.holidays")
        end

        reply_in_not_working_time(client,reason,duty,time,data) if !reason.nil?
      end
    end
  end

  def self.unknown(client:, data:)
    client.web_client.chat_postMessage(
        channel: data.channel,
        text: I18n.t("commands.unknown.text", name: client.self.name),
        thread_ts: data.thread_ts || data.ts,
        as_user: true
    )
  end

end
