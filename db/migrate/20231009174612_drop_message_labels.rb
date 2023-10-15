class DropMessageLabels < ActiveRecord::Migration[6.1]
  def change
    drop_table :message_labels
  end
end
