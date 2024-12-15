class RenameTypeToAnswerTypeInAnswers < ActiveRecord::Migration[6.0]
  def change
    rename_column :answers, :type, :answer_type
  end
end