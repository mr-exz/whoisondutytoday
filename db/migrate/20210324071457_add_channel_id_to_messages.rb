class AddChannelIdToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :channel_id, :string
  end
end
