require 'json'
require_relative '../../lib/slack_formatter'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class TakeALook
      DESCRIPTION = 'Analyze a thread and generate troubleshooting insights using Claude AI'.freeze
      EXAMPLE = '`take a look` or `take a look [custom prompt]` (in a thread)'.freeze

      def self.call(client:, data:, match: nil)
        return unless data.thread_ts

        client.say(channel: data.channel, text: '🔄 Analyzing thread...', thread_ts: data.thread_ts)

        Thread.new do
          begin
            thread_context = collect_thread_context(client, data)
            system_prompt = get_channel_prompt(data.channel)

            # Extract prompt from message or use default
            user_prompt = match && match['expression'] ? match['expression'].strip : ""
            prompt = user_prompt.empty? ? "Following your system instructions, analyze this thread and provide troubleshooting insights." : user_prompt

            claude_output = call_claude(system_prompt, prompt, thread_context)

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

      def self.call_claude(system_prompt, prompt, thread_context = nil)
        require 'fileutils'

        # Create prompts_tmp directory for debugging
        prompts_dir = './prompts_tmp'
        FileUtils.mkdir_p(prompts_dir)

        # Use system prompt or default
        system_prompt ||= "You are a support troubleshooting assistant. Analyze the following support thread and provide helpful troubleshooting steps and insights. Please provide: 1. Summary of the issue, 2. Potential causes, 3. Recommended troubleshooting steps, 4. Any relevant resources or documentation or plugins, 5. Return result in Slack formatting and try be short"

        # Create temp files in prompts_tmp folder
        timestamp = Time.now.strftime('%Y%m%d_%H%M%S_%N')
        system_file_path = "#{prompts_dir}/system_#{timestamp}.txt"
        prompt_file_path = "#{prompts_dir}/prompt_#{timestamp}.txt"

        File.write(system_file_path, system_prompt)
        File.write(prompt_file_path, prompt)

        cmd = "claude --dangerously-skip-permissions --allow-dangerously-skip-permissions " \
              "--disallowedTools \"Bash\" " \
              "--system-prompt \"$(cat #{system_file_path})\" "

        if thread_context
          context_file_path = "#{prompts_dir}/context_#{timestamp}.txt"
          File.write(context_file_path, "for context here is what has been discussed so far:\n\n#{thread_context}")
          cmd += "--append-system-prompt \"$(cat #{context_file_path})\" "
        end

        cmd += "-p \"$(cat #{prompt_file_path})\" 2>&1"

        output = `#{cmd}` rescue ""
        output
      rescue StandardError => e
        puts "Error calling Claude: #{e.message}"
        ""
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
