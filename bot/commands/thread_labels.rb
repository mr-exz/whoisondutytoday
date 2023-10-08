module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ThreadLabels
      def self.call(client:, data:, match:)
        label_ids = []
        match["expression"].split.each do |label|
          label_ids.append(Label.find_or_create_by(label: label).id)
        end
        mp = MessageProcessor.new
        mp.save_message_for_statistic(data: data, labels_ids: label_ids)
      end
    end
  end
end
