class SlackThread < ApplicationRecord
  has_many :slack_thread_labels, dependent: :destroy
  has_many :labels, through: :slack_thread_labels
end
