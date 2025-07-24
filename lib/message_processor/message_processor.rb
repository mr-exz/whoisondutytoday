# lib/message_processor.rb
class MessageProcessor
  def initialize
    @bot_token = ENV['SLACK_BOT_TOKEN'] # Ensure this is set with your Bot User OAuth Token
    @slack_web_client = Slack::Web::Client.new(token: @bot_token)
  end

  def collectUserInfo(data:)
    user_info = @slack_web_client.users_info(user: data.user)
    user = User.find_or_initialize_by(slack_user_id: user_info["user"]["id"])
    if user.new_record? || user.updated_at < 1.day.ago
      user.name = user_info["user"]["name"]
      user.real_name = user_info["user"]["real_name"]
      user.tz = user_info["user"]["tz"]
      user.tz_offset = user_info["user"]["tz_offset"]
      user.contacts = user_info["user"]["profile"]["email"]
      user.save
    end
  end

  def collectUserInfoBySlackUserId(slack_user_id)
    user_info = @slack_web_client.users_info(user: slack_user_id)
    user = User.find_or_initialize_by(slack_user_id: user_info["user"]["id"])
    user.name = user_info["user"]["name"]
    user.real_name = user_info["user"]["real_name"]
    user.tz = user_info["user"]["tz"]
    user.tz_offset = user_info["user"]["tz_offset"]
    user.contacts = user_info["user"]["profile"]["email"]
    user.save
  end

  def save_message_for_reminder(data:)
    message = Message.new
    message.message_id = data.client_msg_id || "undefined"
    message.ts = data.ts
    message.thread_ts = data.thread_ts
    message.event_ts = data.event_ts
    message.channel_id = data.channel
    message.remind_needed = true
    message.reply_counter = 0
    message.save
  end

  def disable_message_from_remind(data:)
    message = Message.where(ts: data.thread_ts).first
    message.remind_needed = false
    message.save
  end

  def save_message(data:)
    message = Message.new
    message.message_id = data.client_msg_id || "undefined"
    message.ts = data.ts
    message.thread_ts = data.thread_ts
    message.event_ts = data.event_ts
    message.channel_id = data.channel
    message.remind_needed = false
    message.reply_counter = 1
    message.save
  end
end
