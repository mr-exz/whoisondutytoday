class AddReminderOptionToChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :reminder_enabled, :boolean
  end
end
