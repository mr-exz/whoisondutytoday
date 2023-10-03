module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class CreateDutyForUser
      def self.call(client:,data:,match:)
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

      def self.set_user_on_duty(data:, client:, slack_user_id:)
        Duty.where(channel_id: data.channel).where(user_id: slack_user_id).update_all(enabled: true)
        Duty.where(channel_id: data.channel).where.not(user_id: slack_user_id).update_all(enabled: false)
        client.say(
          channel: data.channel,
          text: I18n.t('commands.duty.enabled-for-user.text', name: slack_user_id),
          thread_ts: data.thread_ts || data.ts
        )
      end

    end
  end
end