module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ThreadCleanLabels
      def self.call(client:, data:, match:)
        Message.find_by(thread_ts: data.thread_ts).destroy
      end
    end
  end
end
