require_relative '../../bot/commands/main'
namespace :reminder do
  task remind: :environment do
    channels = Channel.where("JSON_EXTRACT(settings, '$.reminder_enabled') = 'true'")

    channels.each do |channel|
      begin
        duty = Duty.where(channel_id: channel.slack_channel_id).where(enabled: true).take!
        reason = WhoIsOnDutyTodaySlackBotModule::Commands::Other.determine_reason(duty)
        unless reason.nil? || reason[:type] == 'working_hours'
          p "Reason to skip reminder:#{reason[:type]}"
          next
        end
      rescue => e
        p e.message
      end

      messages = Message.where(remind_needed: true).where(channel_id: channel.slack_channel_id).where('created_at < ?',
                                                                                                      15.minute.ago)
      next unless messages.any?

      Slack.configure do |config|
        config.token = ENV['SLACK_API_TOKEN']
      end
      @bot_token = ENV['SLACK_BOT_TOKEN'] # Ensure this is set with your Bot User OAuth Token
      client = Slack::Web::Client.new(token: @bot_token)
      permalinks = []
      messages.each do |message|
        options = {}
        options[:message_ts] = message.thread_ts || message.ts
        options[:channel] = message.channel_id
        begin
          message_info = client.chat_getPermalink(options)
          permalinks.append(message_info['permalink'])
        rescue => e
          # delete from database messages which was deleted, to avoid unnecessary reminders
          if e.message == 'message_not_found'
            message.delete
          end
          p e.message
        end
      end

      client.chat_postMessage(
        channel: duty.user_id,
        text: "You have missed messages which require your answer. Check links bellow\n#{permalinks.join("\n")}",
        as_user: true
      )
    end
  end
end
