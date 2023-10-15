class CreateSlackThreadLabels < ActiveRecord::Migration[6.1]
  def change
    create_table :slack_thread_labels do |t|
      t.references :slack_thread, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
      t.timestamps
    end
  end
end
