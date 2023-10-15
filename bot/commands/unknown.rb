module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class Unknown
      def self.call(client:, data:)
        client.web_client.chat_postMessage(
          channel: data.channel,
          text: I18n.t("commands.unknown.text", name: client.self.name),
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )
      end
    end
  end
end
