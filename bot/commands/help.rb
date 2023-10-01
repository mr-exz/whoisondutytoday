class Help
  def self.exec(client:,data:)
    client.web_client.chat_postMessage(
      channel: data.channel,
      text: I18n.t('commands.help.text', version: Whoisondutytoday::Application::VERSION),
      thread_ts: data.thread_ts || data.ts,
      as_user: true
    )
  end
end