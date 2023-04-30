class UpdateReminderEnabledDefaultToFalseChannels < ActiveRecord::Migration[6.1]
  def change
    change_column_default :channels, :reminder_enabled, from: nil, to: false
  end
end
