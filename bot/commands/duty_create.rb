module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class DutyCreate
      DESCRIPTION = 'Will create or update a duty for user. Time should be defined in your local timezone.'.freeze
      EXAMPLE = '`duty create for <username> from <from time> to <to time>` example: `duty create for @user from 8:00 to 17:00`'.freeze
      def self.set_user_on_duty(data:, client:, slack_user_id:)
        Duty.where(channel_id: data.channel).where(user_id: slack_user_id).update_all(enabled: true)
        Duty.where(channel_id: data.channel).where.not(user_id: slack_user_id).update_all(enabled: false)
        client.say(
          channel: data.channel,
          text: I18n.t('commands.duty.enabled-for-user.text', name: slack_user_id),
          thread_ts: data.thread_ts || data.ts
        )
      end


      def self.call(client:, data:, match:)
        message_processor = MessageProcessor.new
        slack_web_client = Slack::Web::Client.new
        channel_info = slack_web_client.conversations_info(channel: data.channel)

        channel = Channel.find_or_initialize_by(slack_channel_id: data.channel)
        channel.name = channel_info['channel']['name']
        channel.slack_channel_id = channel_info['channel']['id']
        channel.description = channel_info['channel']['value']
        channel.save

        user_name = match['expression'][/<@(.+)>/, 1]
        message_processor.collectUserInfoBySlackUserId(user_name)
        user = User.where(slack_user_id: user_name).first

        duty = Duty.find_or_initialize_by(user_id: data.user, channel_id: data.channel)
        duty.duty_from = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match['expression'][/from (\d+:\d+) /, 1].to_time)
        duty.duty_to = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match['expression'][/.* to (\d+:\d+)$/, 1].to_time)
        duty.enabled = true
        duty.save

        client.say(
          channel: data.channel,
          text: I18n.t('commands.duty.created.text', fH: duty.duty_from.hour, fM: duty.duty_from.min, tH: duty.duty_to.hour, tM: duty.duty_to.min, status: duty.enabled),
          thread_ts: data.thread_ts || data.ts
        )
        set_user_on_duty(data: data, client: client, slack_user_id: user_name)
      rescue StandardError => e
        client.say(
          channel: data.channel,
          text: e,
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
