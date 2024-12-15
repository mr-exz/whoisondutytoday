class Answer < ApplicationRecord
  belongs_to :channel
  enum answer_type: { working_time: 'working_time', non_working_time: 'non_working_time' }
end
