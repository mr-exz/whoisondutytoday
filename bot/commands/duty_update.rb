module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class DutyUpdate
      def self.call(client:, data:, match:)
        duty = Duty.where(user_id: data.user, channel_id: data.channel).first

        if duty.blank?
          client.say(
            channel: data.channel,
            text: I18n.t("commands.duty.exist.error"),
            thread_ts: data.thread_ts || data.ts
          )
        else
          user = User.where(slack_user_id: data.user).first
          duty.duty_from = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match["expression"][/from (\d+:\d+) /, 1].to_time)
          duty.duty_to = ActiveSupport::TimeZone.new(user.tz).local_to_utc(match["expression"][/.* to (\d+:\d+)$/, 1].to_time)
          duty.channel_id = data.channel
          duty.user_id = user.id
          duty.enabled = true
          duty.save
          client.say(
            channel: data.channel,
            text: I18n.t("commands.duty.updated.text", fH: duty.duty_from.hour, fM: duty.duty_from.min, tH: duty.duty_to.hour, tM: duty.duty_to.min, status: duty.enabled),
            thread_ts: data.thread_ts || data.ts
          )
          DutyCreate.i_am_on_duty(data: data, client: client)
        end
      end
    end
  end
end
