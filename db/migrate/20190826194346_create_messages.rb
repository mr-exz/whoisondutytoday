class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string      :message_id,  null: false
      t.string      :ts,          null: true
      t.string      :thread_ts,   null: true
      t.string      :event_ts,    null: true
      t.integer     :reply_counter,
      t.timestamps
    end
  end
end
