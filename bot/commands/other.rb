module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class Other
      def self.call(client:, data:, match:)
        log_event("Incoming data: #{data}")
        message_processor = MessageProcessor.new

        # Skip processing events and data without client_msg_id or if type is not message
        return unless data.key?('client_msg_id') && data['type'] == 'message'

        begin
          channel = Channel.where(slack_channel_id: data.channel).first
          return if channel.nil?

          duty = Duty.where(channel_id: data.channel, enabled: true).first
          reason = determine_reason(duty)

          # store messages where reminder needed
          if channel.reminder_enabled == true
            if !data.key?('thread_ts') && (data['user'] != duty.user.slack_user_id)  
              message_processor.save_message_for_reminder(data: data)
            end
            if (data.user == duty.user.slack_user_id) && data.key?('thread_ts')
              message_processor.disable_message_from_remind(data: data)
            end
          end

          # don't reply on duty person messages
          return if data.user == duty.user.slack_user_id

          # Answer if it is known problem
          if !data.nil? && !match.nil?
            Action.where(channel: data.channel).where.not(problem: nil).each do |action|
              /#{action.problem}/i.match(data.text) do |_|
                reply_to_known_problem(client: client, problem: action.problem, data: data, action: action.action)
              end
            end
          end

          # check if message written in channel
          if !data.key?('thread_ts')  
            message_processor.collectUserInfo(data: data)
            handle_message(client, channel, data, reason)
          else
            # check if message written in thread without answer from bot
            message = Message.where('ts=? OR thread_ts=?', data.thread_ts, data.thread_ts).where(reply_counter: 1)
            handle_message(client, channel, data, reason) if message.blank?
          end
        rescue StandardError => e
          print e
        end
      end

      def self.reply_in_not_working_time(client, reason, data)
        answer = Answer.where(channel_id: data.channel, answer_type: 'non_working_time').first

        if answer.nil?
          text = I18n.t('reply.non-working-time.text', name: client.self.name)
        else
          text = answer.body
          if answer.hide_reason
            reason[:text] = ''
          end
        end

        client.web_client.chat_postMessage(
          text: '%s' % reason[:text],
          channel: data.channel,
          attachments: [
            {
              fallback: I18n.t('reply.non-working-time.subject'),
              text: text,
              color: '#3AA3E3',
              attachment_type: 'default'
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
          text: '%s' % I18n.t('reply.known-problem.subject'),
          channel: data.channel,
          attachments: [
            {
              text: "Problem: %s \nAction: %s" % [problem, action],
              color: '#3AA3E3',
              attachment_type: 'default'
            }
          ],
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
        message_processor = MessageProcessor.new
        message_processor.save_message(data: data)
      end

      def self.determine_reason(duty)
        reason = {}
        current_time = Time.now

        if working_time?(current_time, duty)
          reason[:type] = 'working_hours'
          reason[:text] = ''
        else
          from_time = duty.duty_from.utc.strftime('%H:%M').to_s
          to_time = duty.duty_to.utc.strftime('%H:%M').to_s
          reason[:type] = 'non_working_hours'
          reason[:text] =
            I18n.t('reply.reason.non-working-hours.text', fT: from_time, tT: to_time,
                                                          cT: current_time.utc.strftime('%H:%M').to_s)
        end

        unless duty.duty_days.split(',').include?(current_time.utc.strftime('%u'))
          reason[:type] = 'non_working_day'
          reason[:text] = I18n.t('reply.reason.non-working-day.text')
        end

        if duty.user&.status
          reason[:type] = 'user_status'
          reason[:text] = I18n.t('commands.user.status.enabled.text', status: duty.user.status)
        end

        reason
      end

      def self.send_tagged_message(client, channel, data)
        if channel.tag_reporter_enabled
          user_tag = channel.tag_reporter(data.user)
          client.say(
            text: "#{user_tag}, we would appreciate your attention. Thank you!",
            channel: data.channel,
            as_user: true,
            thread_ts: data.thread_ts || data.ts
          )
        end
      end

      def self.auto_answer_at_working_time(client, channel, data)
        if channel.auto_answer_enabled
          answer = Answer.where(channel_id: data.channel, answer_type: 'working_time').first
          unless answer.nil?
            text = answer.body
            client.web_client.chat_postMessage(
              text: '%s' % text,
              channel: data.channel,
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
            message_processor = MessageProcessor.new
            message_processor.save_message(data: data)
          end
        end
      end

      def self.log_event(message)
        logger = Logger.new(STDOUT)
        logger.info(message)
      end

      def self.working_time?(current_time, duty)
        # Check if the current time is within the working hours
        if current_time.utc.strftime('%H%M%S%N') < duty.duty_from.utc.strftime('%H%M%S%N') || current_time.utc.strftime('%H%M%S%N') > duty.duty_to.utc.strftime('%H%M%S%N')
          return false
        end

        true
      end

      def self.handle_message(client, channel, data, reason)
        auto_answer_at_working_time(client, channel, data) if reason[:type] == 'working_hours'

        if %w[non_working_hours non_working_day user_status].include?(reason[:type])
          reply_in_not_working_time(client, reason, data)
        end

        send_tagged_message(client, channel, data)
      end
    end
  end
end
