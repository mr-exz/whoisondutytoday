class Channel < ApplicationRecord
  self.primary_key = 'slack_channel_id'
  def reminder_enabled
    settings.present? && settings['reminder_enabled'] == 'true'
  end

  def reminder_enabled=(value)
    self.settings ||= {}
    self.settings['reminder_enabled'] = value
  end

  def tag_reporter_enabled
    settings.present? && settings['tag_reporter_enabled'] == 'true'
  end

  def tag_reporter_enabled=(value)
    self.settings ||= {}
    self.settings['tag_reporter_enabled'] = value
  end

  def tag_reporter(user_id)
    tag_reporter_enabled ? "<@#{user_id}>" : ''
  end

  def auto_answer_enabled
    settings.present? && settings['auto_answer_enabled'] == 'true'
  end

  def auto_answer_enabled=(value)
    self.settings ||= {}
    self.settings['auto_answer_enabled'] = value
  end
end
