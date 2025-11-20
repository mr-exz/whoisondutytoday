require 'json'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class TakeALook
      def self.call(client:, data:)
        # Only process messages in threads
        return unless data.thread_ts

        # Send immediate response to indicate processing
        client.say(channel: data.channel, text: '🔄 Analyzing thread...', thread_ts: data.thread_ts)

        # Start background processing thread to avoid blocking other messages
        Thread.new do
          begin
            # Collect thread context
            thread_context = collect_thread_context(client, data)

            # Call Claude via system command in background
            claude_output = call_claude(thread_context)

            # Post results to thread
            if claude_output.empty?
              post_response(client, data, '⚠️ No analysis available', thread_ts: data.thread_ts)
            else
              # Split long messages to respect Slack's 4000 character limit
              post_response(client, data, claude_output, thread_ts: data.thread_ts)
            end
          rescue StandardError => e
            puts "Error in TakeALook: #{e.class} - #{e.message}"
            puts e.backtrace
            post_response(client, data, "❌ Error during analysis: #{e.message}", thread_ts: data.thread_ts)
          end
        end
      end

      private

      def self.collect_thread_context(client, data)
        # Get all messages in thread
        messages = []

        # Get thread messages using Slack API
        begin
          thread_messages = client.web_client.conversations_replies(
            channel: data.channel,
            ts: data.thread_ts
          )

          thread_messages['messages'].each do |msg|
            messages << {
              user: msg['user'],
              text: msg['text'],
              timestamp: msg['ts'],
              thread_ts: msg['thread_ts']
            }
          end
        rescue StandardError => e
          puts "Error fetching thread messages: #{e.message}"
        end

        # Format context for Claude
        formatted_context = messages.map do |msg|
          "#{msg[:user]}: #{msg[:text]}"
        end.join("\n\n")

        {
          channel: data.channel,
          thread_ts: data.thread_ts,
          context: formatted_context,
          request_user: data.user
        }
      end

      def self.call_claude(thread_context)
        require 'tempfile'

        # Prepare prompt with thread context
        prompt = <<~PROMPT
          You are a support troubleshooting assistant. Analyze the following support thread and provide helpful troubleshooting steps and insights.

          Thread Context:
          ```
          #{thread_context[:context]}
          ```

          Please provide:
          1. Summary of the issue
          2. Potential causes
          3. Recommended troubleshooting steps
          4. Any relevant resources or documentation
        PROMPT

        # Write prompt to temporary file to avoid shell escaping issues
        temp_file = Tempfile.new('claude_prompt_')
        temp_file.write(prompt)
        temp_file.close

        begin
          # Call Claude via system command with MCPs available and skipped permissions
          # Use file input instead of command line to safely handle special characters
          output = `claude -p "$(cat #{temp_file.path})" --dangerously-skip-permissions 2>&1` rescue ""
          output
        rescue StandardError => e
          puts "Error calling Claude: #{e.class} - #{e.message}"
          ""
        ensure
          temp_file.unlink if temp_file
        end
      rescue StandardError => e
        puts "Error calling Claude: #{e.class} - #{e.message}"
        ""
      end

      def self.post_response(client, data, message, thread_ts: nil)
        # Split message if it exceeds Slack's character limit
        if message.length > 4000
          messages = message.scan(/.{1,4000}/m)
          messages.each_with_index do |msg, index|
            begin
              client.say(
                channel: data.channel,
                text: msg,
                thread_ts: thread_ts
              )
              # Small delay between messages to avoid rate limiting
              sleep 0.1 if index < messages.length - 1
            rescue StandardError => e
              puts "Error posting response: #{e.class} - #{e.message}"
            end
          end
        else
          begin
            client.say(
              channel: data.channel,
              text: message,
              thread_ts: thread_ts
            )
          rescue StandardError => e
            puts "Error posting response: #{e.class} - #{e.message}"
          end
        end
      end
    end
  end
end
