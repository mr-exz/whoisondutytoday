class AddSettingsToChannels < ActiveRecord::Migration[7.0]
  def change
    add_column :channels, :settings, :json

    reversible do |dir|
      dir.up do
        Channel.reset_column_information
        Channel.where.not(reminder_enabled: nil).find_each do |channel|
          channel.update(settings: (channel.settings || {}).merge('reminder_enabled' => channel.reminder_enabled))
        end
      end
    end

    remove_column :channels, :reminder_enabled, :boolean
  end
end
