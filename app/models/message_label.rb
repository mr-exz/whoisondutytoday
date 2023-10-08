class MessageLabel < ApplicationRecord
  belongs_to :message
  belongs_to :label
end
