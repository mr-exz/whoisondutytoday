module SlackFormatter
  def self.markdown_to_slack(text)
    # Convert markdown to Slack format
    result = text.dup

    # Headers: # Title → *Title*
    result.gsub!(/^### (.*?)$/, '*\1*')
    result.gsub!(/^## (.*?)$/, '*\1*')
    result.gsub!(/^# (.*?)$/, '*\1*')

    # Bold: **text** → *text*
    result.gsub!(/\*\*(.*?)\*\*/, '*\1*')

    # Italic: _text_ → _text_ (already correct)
    result.gsub!(/_(.+?)_/, '_\1_')

    # Links: [text](url) → <url|text>
    result.gsub!(/\[(.*?)\]\((.*?)\)/, '<\2|\1>')

    # Code blocks, inline code, lists, blockquotes are already in correct Slack format

    result
  end
end
