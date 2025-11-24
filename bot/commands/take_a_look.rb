require 'json'
require_relative '../../lib/slack_formatter'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class TakeALook
      DESCRIPTION = 'Analyze a thread and generate troubleshooting insights using Claude AI'.freeze
      EXAMPLE = '`take a look` (in a thread)'.freeze

      def self.call(client:, data:)
        return unless data.thread_ts

        client.say(channel: data.channel, text: '🔄 Analyzing thread...', thread_ts: data.thread_ts)

        Thread.new do
          begin
            thread_context = collect_thread_context(client, data)
            system_prompt = get_channel_prompt(data.channel)
            claude_output = call_claude(system_prompt, thread_context)

            if claude_output.empty?
              message = '⚠️ No analysis available'
            else
              message = SlackFormatter.markdown_to_slack(claude_output)
            end
            post_response(client, data, message, thread_ts: data.thread_ts)
          rescue StandardError => e
            puts "Error in TakeALook: #{e.class} - #{e.message}"
            post_response(client, data, "❌ Error: #{e.message}", thread_ts: data.thread_ts)
          end
        end
      end

      private

      def self.collect_thread_context(client, data)
        thread_messages = client.web_client.conversations_replies(channel: data.channel, ts: data.thread_ts)
        thread_messages['messages'].map do |msg|
          "#{msg['user']}: #{msg['text']}"
        end.join("\n\n")
      rescue StandardError => e
        puts "Error fetching thread: #{e.message}"
        ""
      end

      def self.call_claude(system_prompt, thread_context)
        require 'tempfile'

        # Use system prompt or default
        system_prompt ||= "You are a support troubleshooting assistant. Analyze the following support thread and provide helpful troubleshooting steps and insights. Please provide: 1. Summary of the issue, 2. Potential causes, 3. Recommended troubleshooting steps, 4. Any relevant resources or documentation or plugins, 5. Return result in Slack formatting and try be short"

        # Build full prompt with thread context embedded
        full_prompt = "#{system_prompt}\n\nThread Context:\n```\n#{thread_context}\n```"

        prompt_file = Tempfile.new('claude_prompt_')
        prompt_file.write(full_prompt)
        prompt_file.close

        cmd = "claude --dangerously-skip-permissions --allow-dangerously-skip-permissions " \
              "--disallowedTools \"Bash\" " \
              "-p \"$(cat #{prompt_file.path})\" 2>&1"

        output = `#{cmd}` rescue ""
        output
      rescue StandardError => e
        puts "Error calling Claude: #{e.message}"
        ""
      ensure
        prompt_file.unlink if prompt_file
      end

      def self.post_response(client, data, message, thread_ts: nil)
        message.scan(/.{1,4000}/m).each_with_index do |msg, index|
          client.say(channel: data.channel, text: msg, thread_ts: thread_ts)
          sleep 0.1 if index > 0
        rescue StandardError => e
          puts "Error posting: #{e.message}"
        end
      end

      def self.get_channel_prompt(channel_id)
        ChannelPrompt.get_prompt(channel_id)
      rescue => e
        puts "Error fetching channel prompt: #{e.message}"
        ""
      end

    end
  end
end
