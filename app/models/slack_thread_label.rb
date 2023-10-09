class SlackThreadLabel < ApplicationRecord
  belongs_to :slack_thread
  belongs_to :label
end
