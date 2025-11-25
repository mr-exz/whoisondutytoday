require 'json'
require_relative '../../lib/slack_formatter'

module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ClaudePrompt
      DESCRIPTION = 'Send a custom prompt to Claude AI'.freeze
      EXAMPLE = '`claude <your prompt here>` example: `claude /answers-troubleshooting:analyze-errors last 3 days`'.freeze

      def self.call(client:, data:, match:)
        prompt = match['expression'].strip
        return if prompt.empty?

        thread_ts = data.thread_ts || data.ts

        client.say(channel: data.channel, text: '🤖 Processing...', thread_ts: thread_ts)

        Thread.new do
          begin
            system_prompt = get_channel_prompt(data.channel)
            thread_context = collect_thread_context(client, data, thread_ts)
            claude_output = call_claude(system_prompt, prompt, thread_context)

            if claude_output.empty?
              message = '⚠️ No response'
            else
              message = SlackFormatter.markdown_to_slack(claude_output)
            end
            post_response(client, data, message, thread_ts: thread_ts)
          rescue StandardError => e
            puts "Error in ClaudePrompt: #{e.message}"
            post_response(client, data, "❌ Error: #{e.message}", thread_ts: thread_ts)
          end
        end
      end

      private

      def self.collect_thread_context(client, data, thread_ts)
        thread_messages = client.web_client.conversations_replies(channel: data.channel, ts: thread_ts)
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

      def self.get_channel_prompt(channel_id)
        ChannelPrompt.get_prompt(channel_id)
      rescue => e
        puts "Error fetching channel prompt: #{e.message}"
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
    end
  end
end
