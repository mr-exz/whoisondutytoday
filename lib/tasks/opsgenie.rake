require_relative '../../bot/commands/main'
require_relative '../../lib/opsgenie/notify_opsgenie'

namespace :opsgenie do
  task rotate: :environment do
    opsgenie_schedules = Duty.where.not(opsgenie_schedule_name: nil)
                             .or(Duty.where(opsgenie_schedule_name: ""))
                             .map(&:opsgenie_schedule_name)
                             .uniq
    notification = NotifyOpsgenie.new

    opsgenie_schedules.each do |schedule_name|
      begin
        response = notification.GetOnCall(schedule_name: schedule_name)
        json_response = JSON.parse(response.body)

        if json_response["data"] && json_response["data"]["onCallRecipients"] && json_response["data"]["onCallRecipients"][0]
          recipient = json_response["data"]["onCallRecipients"][0]
          user = User.where("lower(contacts) = ?", recipient.downcase).first

          if user
            duties = Duty.where(user_id: user.slack_user_id, opsgenie_schedule_name: schedule_name)
            duties.each do |duty|
              if duty.enabled && duty.user_id == user.slack_user_id
                puts "Schedule for user already active: #{duty.user.name}"
              else
                puts "Rotating schedule for user: #{duty.user.name}"
                Duty.where(channel_id: duty.channel_id).where(user_id: user.slack_user_id).update_all(enabled: true)
                Duty.where(channel_id: duty.channel_id).where.not(user_id: user.slack_user_id).update_all(enabled: false)
              end
            end
          else
            puts "No user found for recipient: #{recipient}"
          end
        else
          puts "No on-call recipients found for schedule: #{schedule_name}"
        end
      rescue StandardError => e
        puts "An error occurred while processing schedule #{schedule_name}: #{e.message}"
      end
    end
  end
end