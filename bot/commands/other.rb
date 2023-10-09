module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class Other
      def self.call(client:, data:, match:)
        message_processor = MessageProcessor.new
        time = DateTime.strptime(data.ts, "%s")

        # skip processing events and data without client_msg_id
        return if (data.respond_to?(:client_msg_id) == false) && (data.respond_to?(:files) == false)

        begin
          channel = Channel.where(slack_channel_id: data.channel).first
          return if channel.nil?
          duty = Duty.where(channel_id: data.channel, enabled: true).first
          answer = Answer.where(channel_id: data.channel).first

          # store messages where reminder needed
          if channel.reminder_enabled == true
            message_processor.save_message_for_reminder(data: data) if (data.respond_to?(:thread_ts) == false) && (data.user != duty.user.slack_user_id)
            message_processor.disable_message_from_remind(data: data) if (data.user == duty.user.slack_user_id) && (data.respond_to?(:thread_ts) == true)
          end

          # don't reply on duty person messages
          return if data.user == duty.user.slack_user_id

          # Answer if it is known problem
          if !data.nil? && !match.nil?
            Action.where(channel: data.channel).each do |action|
              /#{action.problem}/i.match(data.text) do |_|
                reply_to_known_problem(client: client, problem: action.problem, data: data, action: action.action)
              end
            end
          end

          # check if message written in channel
          if data.respond_to?(:thread_ts) == false
            message_processor.collectUserInfo(data: data)
            reason = self.answer(time, duty)
            reply_in_not_working_time(client, reason, data, answer) unless reason.nil?
            return
          end

          # check if message written in thread without answer from bot
          message = Message.where("ts=? OR thread_ts=?", data.thread_ts, data.thread_ts).where(reply_counter: 1)
          if message.blank?
            reason = self.answer(time, duty)
            reply_in_not_working_time(client, reason, data, answer) unless reason.nil?
          end
        rescue => e
          print e
        end
      end

      def self.reply_in_not_working_time(client, reason, data, answer)
        if answer.nil?
          text = I18n.t("reply.non-working-time.text", name: client.self.name)
        else
          text = answer.body
          if answer.hide_reason == 1
            reason = ""
          end
        end

        client.web_client.chat_postMessage(
          text: "%s" % reason,
          channel: data.channel,
          attachments: [
            {
              fallback: I18n.t("reply.non-working-time.subject"),
              text: text,
              color: "#3AA3E3",
              attachment_type: "default"
            }
          ],
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
        message_processor = MessageProcessor.new
        message_processor.save_message(data: data)
      end

      def self.reply_to_known_problem(client:, problem:, data:, action:)
        client.web_client.chat_postMessage(
          text: "%s" % I18n.t("reply.known-problem.subject"),
          channel: data.channel,
          attachments: [
            {
              text: "Problem: %s \nAction: %s" % [problem, action],
              color: "#3AA3E3",
              attachment_type: "default"
            }
          ],
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
        message_processor = MessageProcessor.new
        message_processor.save_message(data: data)
      end

      def self.answer(time, duty)
        reason = nil

        if (time.utc.strftime("%H%M%S%N") < duty.duty_from.utc.strftime("%H%M%S%N")) || (time.utc.strftime("%H%M%S%N") > duty.duty_to.utc.strftime("%H%M%S%N"))
          from_time = duty.duty_from.utc.strftime("%H:%M").to_s
          to_time = duty.duty_to.utc.strftime("%H:%M").to_s
          current_time = time.utc.strftime("%H:%M").to_s
          reason = I18n.t("reply.reason.non-working-hours.text", fT: from_time, tT: to_time, cT: current_time)
        end

        unless duty.duty_days.split(",").include?(time.utc.strftime("%u"))
          reason = I18n.t("reply.reason.non-working-day.text")
        end

        if !duty.user.status.nil? || !duty.user.status == "work"
          reason = I18n.t("commands.user.status.enabled.text", status: duty.user.status)
        end

        reason
      end
    end
  end
end
