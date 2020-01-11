class MessageProcessor

  def initialize
    @slack_web_client = Slack::Web::Client.new
  end

  def collectUserInfo(data:)
    user = User.where(slack_user_id: data.user).first
    if user.blank?
      user_info = @slack_web_client.users_info(user: data.user)

      user = User.new
      user.slack_user_id = user_info['user']['id']
      user.name = user_info['user']['name']
      user.real_name = user_info['user']['real_name']
      user.tz = user_info['user']['tz']
      user.tz_offset = user_info['user']['tz_offset']
      user.contacts = user_info['user']['profile']['email']
      user.save
    end
  end
end