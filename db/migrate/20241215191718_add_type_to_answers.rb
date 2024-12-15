class AddTypeToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :answers, :type, :string
  end
end
