class CreateSlackThreads < ActiveRecord::Migration[6.1]
  def change
    create_table :slack_threads do |t|
      t.datetime :thread_ts, null: true
      t.string :channel_id
      t.timestamps
    end
  end
end
