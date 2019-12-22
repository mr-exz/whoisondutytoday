class Duty < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :channel, required: true
end
