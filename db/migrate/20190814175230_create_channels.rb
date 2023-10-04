class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels, id: false do |t|
      t.string :slack_channel_id, primary: true, index: {unique: true}
      t.string :name
      t.text :description
      t.timestamps
    end
  end
end
