class ChangeHideReasonToBooleanInAnswers2 < ActiveRecord::Migration[7.0]
  def change
    change_column :answers, :hide_reason, :boolean
  end
end