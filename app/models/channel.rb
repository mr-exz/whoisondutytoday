class Channel < ApplicationRecord
  self.primary_key = 'slack_channel_id'

  def reminder_enabled
    settings['reminder_enabled']
  end

  def reminder_enabled=(value)
    self.settings ||= {}
    self.settings['reminder_enabled'] = value
  end

  def tag_reporter_enabled
    settings['tag_reporter_enabled']
  end

  def tag_reporter_enabled=(value)
    self.settings ||= {}
    self.settings['tag_reporter_enabled'] = value
  end
  def tag_reporter(user_id)
    tag_reporter_enabled ? "<@#{user_id}>" : ""
  end

  def auto_answer_enabled
    settings['auto_answer_enabled']
  end

  def auto_answer_enabled=(value)
    self.settings ||= {}
    self.settings['auto_answer_enabled'] = value
  end
end
