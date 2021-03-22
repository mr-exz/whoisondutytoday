class AddChannelIdToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :channel_id, :string
  end
end
