module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ThreadLabels
      DESCRIPTION = 'Will label the thread with any label. Use space as a separator.'.freeze
      EXAMPLE = '`thread labels <label>` example: `thread labels label1 label2`'.freeze
      def self.call(client:, data:, match:)
        label_ids = []
        match['expression'].split.each do |label|
          label_ids.append(Label.find_or_create_by(label: label).id)
        end
        r = SlackThread.find_or_create_by(thread_ts:data.thread_ts)
        r.thread_ts = data.thread_ts
        r.channel_id = data.channel
        r.label_ids = label_ids

        if r.save
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.thread.labeled.success',labels:match['expression'].split.to_s),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: I18n.t('commands.thread.labeled.error'),
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end
    end
  end
end
