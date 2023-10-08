class Message < ApplicationRecord
  has_many :message_labels, dependent: :destroy
  has_many :labels, through: :message_labels
end
