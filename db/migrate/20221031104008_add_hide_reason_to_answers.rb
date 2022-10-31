class AddHideReasonToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :hide_reason, :bool
  end
end