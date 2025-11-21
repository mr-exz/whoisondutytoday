class ChannelPrompt < ApplicationRecord
  belongs_to :channel, foreign_key: :channel_id, primary_key: :slack_channel_id

  validates :channel_id, presence: true, uniqueness: true
  validates :prompt_text, presence: true

  def self.get_prompt(channel_id)
    find_by(channel_id: channel_id)&.prompt_text
  end

  def self.set_prompt(channel_id, prompt_text)
    prompt = find_or_create_by(channel_id: channel_id)
    prompt.update(prompt_text: prompt_text)
    prompt
  end

  def self.delete_prompt(channel_id)
    find_by(channel_id: channel_id)&.destroy
  end
end
