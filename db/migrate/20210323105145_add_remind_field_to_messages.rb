class AddRemindFieldToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :remind_needed, :boolean
  end
end
