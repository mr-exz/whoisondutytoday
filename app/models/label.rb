class Label < ApplicationRecord
  has_many :slack_thread_labels, dependent: :destroy
  validates_uniqueness_of :label
end
