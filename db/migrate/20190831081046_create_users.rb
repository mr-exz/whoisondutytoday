class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: false do |t|
      t.string :slack_user_id, primary: true, index: {unique: true}
      t.string :name
      t.string :real_name
      t.string :contacts
      t.string :tz
      t.integer :tz_offset
      t.timestamps
    end
  end
end
