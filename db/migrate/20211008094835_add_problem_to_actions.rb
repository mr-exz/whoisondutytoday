class AddProblemToActions < ActiveRecord::Migration[5.2]
  def change
    add_column :actions, :problem, :string
    add_column :actions, :action, :string
  end
end
