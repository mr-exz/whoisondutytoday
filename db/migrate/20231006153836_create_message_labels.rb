class CreateMessageLabels < ActiveRecord::Migration[6.1]
  def change
    create_table :message_labels do |t|
      t.references :message, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
      t.timestamps
    end
  end
end
