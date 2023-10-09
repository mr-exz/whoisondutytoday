class ChangeTsTypeForSlackThreads < ActiveRecord::Migration[6.1]
  def change
    change_table :slack_threads do |t|
      t.change :thread_ts, :string
    end
  end
end
