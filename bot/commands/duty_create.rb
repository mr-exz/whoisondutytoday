module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class DutyCreate
      DESCRIPTION = 'Will create a duty. Time should be defined in your local timezone.'.freeze
      EXAMPLE = '`duty create from <from time> to <to time>` example: `duty create from 8:00 to 17:00`'.freeze
      def self.i_am_on_duty(data:, client:)
        Duty.where(channel_id: data.channel).where(user_id: data.user).update_all(enabled: true)
        Duty.where(channel_id: data.channel).where.not(user_id: data.user).update_all(enabled: false)
        client.say(
          channel: data.channel,
          text: I18n.t('commands.duty.enabled.text'),
          thread_ts: data.thread_ts || data.ts
        )
      end

      def self.call(client:, data:, match:)
        message_processor = MessageProcessor.new
        slack_web_client = Slack::Web::Client.new
        begin
          channel_info = slack_web_client.channels_info(channel: data.channel)
        rescue
          channel_info = {}
          channel_info['channel'] = {}
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
    end
  end
end
