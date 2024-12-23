module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ActionShowAction
      DESCRIPTION = 'Will display action for mentioned problem'.freeze
      EXAMPLE = '`action show action for problem:<exact substring>` example: `action show action for problem:MyProblem`'.freeze
      def self.call(client:, data:, match:)
        problem_text = match['expression'][/problem:(.*)$/, 1]
        problems = Action.where('channel = ? AND problem LIKE ?', data.channel, "%#{problem_text}%")

        if problems.any?
          attachments = problems.map do |problem|
            {
              fallback: "Problem: #{problem.problem}",
              color: '#36a64f',
              fields: [
                {
                  title: 'Problem',
                  value: problem.problem,
                  short: false
                },
                {
                  title: 'Action',
                  value: problem.action,
                  short: false
                }
              ]
            }
          end

          client.web_client.chat_postMessage(
            channel: data.channel,
            text: 'Here are the problems and their actions:',
            attachments: attachments,
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: 'No problems with actions found for this channel.',
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end
