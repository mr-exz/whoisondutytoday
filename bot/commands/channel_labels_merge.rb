module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ChannelLabelsMerge
      def self.call(client:, data:, match:)
        label_from = match["expression"][/from:(.*) action:/, 1]
        label_to = match["expression"][/ to:(.*)$/, 1]
        label_to_id = Label.where(label: label_to).ids[0]

        if (label_from != nil?) || (label_to_id != nil?)
          m = SlackThreadLabel.joins(:label, :slack_thread).where(slack_thread: {channel_id: data.channel}, label: {label: label_from})
          m.update_all(label_id: label_to_id)
          message = "label_from label_to merged"
        else
          message = "Sorry, label_from or label_to not found, merge not possible."
        end
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: message,
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )

      end
    end
  end
end
