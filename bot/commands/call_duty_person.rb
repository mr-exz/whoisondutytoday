module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class CallDutyPerson

      DESCRIPTION = 'Will send an alert message to the duty person.'.freeze
      EXAMPLE = '`call duty person`'.freeze
      def self.call(client:, data:)
        duty = Duty.where(channel_id: data.channel).where(enabled: true).take!
        @bot_token = ENV['SLACK_BOT_TOKEN'] # Ensure this is set with your Bot User OAuth Token
        slack_web_client = Slack::Web::Client.new(token: @bot_token)

        client_info = slack_web_client.users_info(user: data.user)
        options = {}
        options[:message_ts] = data.thread_ts || data.ts
        options[:channel] = data.channel
        message_info = slack_web_client.chat_getPermalink(options)
        notification = NotifyOpsgenie.new

        recipient = {}
        if !duty.opsgenie_escalation_name.nil?
          recipient['name'] = duty.opsgenie_escalation_name
          recipient['type'] = 'escalation'
          recipient['field_name'] = 'name'
        elsif !duty.opsgenie_schedule_name.nil?
          recipient['name'] = duty.opsgenie_schedule_name
          recipient['type'] = 'schedule'
          recipient['field_name'] = 'name'
        else
          recipient['name'] = duty.user.contacts
          recipient['type'] = 'user'
          recipient['field_name'] = 'username'
        end

        response = notification.send(recipient, client_info, message_info)

        json_response = JSON.parse(response.body)

        if !json_response['result'].nil?
          reply = I18n.t('reply.opsgenie.text')
        elsif !json_response['message'].nil?
          reply = I18n.t('reply.opsgenie.error', message: json_response['message'])
        end

        client.say(
          channel: data.channel,
          text: reply,
          thread_ts: data.thread_ts || data.ts
        )
      end
    end
  end
end
