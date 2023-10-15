class Label < ApplicationRecord
  has_many :slack_thread_labels, dependent: :destroy
  has_many :messages, through: :slack_thread_labels
  validates_uniqueness_of :label
end
