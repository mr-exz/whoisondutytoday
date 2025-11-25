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
            prompts_dir = if data.channel && thread_ts
              "./prompts_tmp/#{data.channel}/p#{thread_ts}"
            else
              "./prompts_tmp"
            end
            FileUtils.mkdir_p(prompts_dir)
            thread_context = collect_thread_context(client, data, thread_ts, prompts_dir)
            claude_output = call_claude(system_prompt, prompt, thread_context, data.channel, thread_ts)

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

      def self.collect_thread_context(client, data, thread_ts, prompts_dir = nil)
        thread_messages = client.web_client.conversations_replies(channel: data.channel, ts: thread_ts)

        thread_messages['messages'].filter_map do |msg|
          next unless msg['text']

          user_id = msg['user'] || msg['bot_id'] || "unknown"
          message_text = msg['text']
          context_line = "channel_id: #{data.channel} user_id: #{user_id} message_text: #{message_text}"

          # Download and save files if present
          if msg['files'] && prompts_dir
            msg['files'].each do |file|
              begin
                download_and_save_file(client, file, prompts_dir)
                context_line += "\nfile: #{file['name']}"
              rescue => e
                puts "Error downloading file #{file['name']}: #{e.message}"
              end
            end
          end

          context_line
        end.join("\n\n")
      rescue StandardError => e
        puts "Error fetching thread: #{e.message}"
        ""
      end

      def self.download_and_save_file(client, file, prompts_dir)
        filename = file['name']
        filepath = "#{prompts_dir}/#{filename}"

        response = client.web_client.files_info(file: file['id'])
        file_url = response['file']['url_private']

        # Download file with Slack authentication and follow redirects
        require 'net/http'
        uri = URI(file_url)
        body = download_with_redirects(uri, client.web_client.token)
        File.binwrite(filepath, body)
      end

      def self.download_with_redirects(uri, token, limit = 5)
        raise 'Too many redirects' if limit == 0

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request['Authorization'] = "Bearer #{token}"

        response = http.request(request)

        case response
        when Net::HTTPSuccess
          response.body
        when Net::HTTPRedirection
          new_uri = URI(response['location'])
          download_with_redirects(new_uri, token, limit - 1)
        else
          raise "Failed to download: #{response.code}"
        end
      end

      def self.call_claude(system_prompt, prompt, thread_context = nil, channel_id = nil, thread_ts = nil)
        require 'fileutils'

        # Create prompts_tmp/channel/thread folder structure
        prompts_dir = if channel_id && thread_ts
          "./prompts_tmp/#{channel_id}/p#{thread_ts}"
        else
          "./prompts_tmp"
        end
        FileUtils.mkdir_p(prompts_dir)

        # Create temp files with simple names
        system_file_path = "#{prompts_dir}/system.txt"
        prompt_file_path = "#{prompts_dir}/prompt.txt"

        File.write(system_file_path, system_prompt)
        File.write(prompt_file_path, prompt)

        cmd = "cd #{prompts_dir} && claude --dangerously-skip-permissions --allow-dangerously-skip-permissions " \
              "--disallowedTools \"Bash\" " \
              "--system-prompt \"$(cat system.txt)\" "

        if thread_context
          context_file_path = "#{prompts_dir}/context.txt"
          File.write(context_file_path, "for context here is what has been discussed so far:\n\n#{thread_context}")
          cmd += "--append-system-prompt \"$(cat context.txt)\" "
        end

        cmd += "-p \"$(cat prompt.txt)\" 2>&1"

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
