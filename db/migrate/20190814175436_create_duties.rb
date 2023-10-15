class CreateDuties < ActiveRecord::Migration[5.2]
  def change
    create_table :duties do |t|
      t.timestamp :duty_from, null: false
      t.timestamp :duty_to, null: false
      t.string :duty_days, default: "1,2,3,4,5" # 1 - monday
      t.string :channel_id, null: false
      t.string :user_id, null: false
      t.boolean :enabled
      t.timestamps
    end
  end
end
