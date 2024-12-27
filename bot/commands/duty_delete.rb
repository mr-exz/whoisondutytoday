module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class DutyDelete

      DESCRIPTION = 'Will delete a duty in channel where you write it.'.freeze
      EXAMPLE = '`duty delete for <user>` example `duty delete for @user` or `duty delete for @all` to delete all'.freeze
      def self.call(client:, data:, match:)
        user_name = match['expression'][/@(.+)/, 1]

        if user_name == 'all'
          duties = Duty.where(channel_id: data.channel)
          deleted_duties = duties.pluck(:user_id)
          duties.delete_all
          client.say(
            channel: data.channel,
            text: "Deleted duties for user id's: #{deleted_duties.join(', ')}",
            thread_ts: data.thread_ts || data.ts
          )
        else
          duty = Duty.where(user_id: user_name, channel_id: data.channel).first
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
