class AddOpsgenieScheduleNameToDuties < ActiveRecord::Migration[5.2]
  def change
    add_column :duties, :opsgenie_schedule_name, :string
  end
end
