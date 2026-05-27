class Label < ApplicationRecord
  has_many :slack_thread_labels, dependent: :destroy
  validates :label, uniqueness: true
end
