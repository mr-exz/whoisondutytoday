class AddChannelToActions < ActiveRecord::Migration[5.2]
  def change
    add_column :actions, :channel, :string
  end
end
