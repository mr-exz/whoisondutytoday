class CreateChannelPrompts < ActiveRecord::Migration[6.0]
  def change
    create_table :channel_prompts do |t|
      t.string :channel_id, null: false, unique: true, index: true
      t.text :prompt_text, null: false
      t.timestamps
    end

    # Add foreign key constraint
    add_foreign_key :channel_prompts, :channels, column: :channel_id, primary_key: :slack_channel_id
  end
end
