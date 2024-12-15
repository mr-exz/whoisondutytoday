class Channel < ApplicationRecord
  self.primary_key = 'slack_channel_id'

  def reminder
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
end
