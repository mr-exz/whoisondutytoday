import 'bot/commands.rb'

namespace :reminder do
  task :remind => :environment do
    channels = Channel.where(reminder_enabled: true)

    channels.each do |channel|
      duty = Duty.where(channel_id: channel.slack_channel_id).where(enabled: true).take!
      time = DateTime.now
      reason = Commands.answer(time,duty)
      unless reason.nil?
        p "Reason to skip reminder:" + reason
        break
      end

      messages = Message.where(remind_needed: true).where(channel_id: channel.slack_channel_id).where("created_at < ?", 15.minute.ago)
      if messages.any?
        Slack.configure do |config|
          config.token = ENV['SLACK_API_TOKEN']
        end

        client = Slack::Web::Client.new
        permalinks = []
        messages.each do |message|
          options = {}
          options[:message_ts] = message.thread_ts || message.ts
          options[:channel] = message.channel_id
          message_info = client.chat_getPermalink(options)
          permalinks.append(message_info['permalink'])
        end


        client.chat_postMessage(
          channel: duty.user_id,
          text:  "You have missed messages which require your answer. Check links bellow\n"+permalinks.join("\n"),
          as_user: true
        )
      end
    end

  end
end
