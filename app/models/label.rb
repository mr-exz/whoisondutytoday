class Label < ApplicationRecord
  has_many :message_labels, dependent: :destroy
  has_many :messages, through: :message_labels
  validates_uniqueness_of :label
end
