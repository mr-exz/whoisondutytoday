class AddOpsgenieEscalationNameToDuties < ActiveRecord::Migration[5.2]
  def change
    add_column :duties, :opsgenie_escalation_name, :string
  end
end
