module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ActionShowProblems
      DESCRIPTION = 'Will display problems for this channel'.freeze
      EXAMPLE = '`action show problems`'.freeze
      def self.call(client:, data:)
        problems = Action.where(channel: data.channel).where.not(action: nil)

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
                  title: 'Solution',
                  value: problem.action,
                  short: false
                }
              ]
            }
          end

          client.web_client.chat_postMessage(
            channel: data.channel,
            text: 'Here are the problems and their solutions:',
            attachments: attachments,
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: 'No problems with solutions found for this channel.',
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end
