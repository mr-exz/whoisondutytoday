module WhoIsOnDutyTodaySlackBotModule
  module Commands
    class ClaudePluginSync
      DESCRIPTION = 'Sync Claude plugin repository and return head commit'.freeze
      EXAMPLE = '`claude plugin sync`'.freeze

      def self.call(client:, data:, match: nil)
        plugin_repo_url = ENV['PLUGIN_REPO_URL']
        plugins_dir = ENV['PLUGINS_DIR'] || '/opt/app/plugins'

        unless plugin_repo_url
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: '❌ PLUGIN_REPO_URL environment variable not set',
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
          return
        end

        client.web_client.chat_postMessage(
          channel: data.channel,
          text: 'Syncing Claude plugin repository...',
          thread_ts: data.thread_ts || data.ts,
          as_user: true
        )

        # Execute git pull
        result = sync_plugin_repo(plugins_dir)

        if result[:success]
          head_commit = get_head_commit(plugins_dir)

          if head_commit
            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "✅ Plugin repository synced\n" \
                    "Commit: `#{head_commit[:hash]}`\n" \
                    "Author: #{head_commit[:author]}\n" \
                    "Date: #{head_commit[:date]}\n" \
                    "Message: #{head_commit[:message]}",
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
          else
            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "✅ Plugin repository synced but couldn't read commit info",
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
          end

          # Now install/reinstall plugins
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: 'Installing/reinstalling Claude plugins...',
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )

          install_result = install_plugins(plugins_dir)
          if install_result[:success]
            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "✅ Plugins installed successfully\n#{install_result[:message]}",
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
          else
            client.web_client.chat_postMessage(
              channel: data.channel,
              text: "⚠️ Plugin installation completed with issues\n#{install_result[:message]}",
              thread_ts: data.thread_ts || data.ts,
              as_user: true
            )
          end
        else
          client.web_client.chat_postMessage(
            channel: data.channel,
            text: "❌ Failed to sync plugin repository\nError: #{result[:error]}",
            thread_ts: data.thread_ts || data.ts,
            as_user: true
          )
        end
      end

      private

      def self.sync_plugin_repo(plugins_dir)
        begin
          # Check if directory exists and is a git repo
          unless File.directory?(plugins_dir) && File.directory?(File.join(plugins_dir, '.git'))
            return { success: false, error: 'Plugin directory does not exist or is not a git repository' }
          end

          # Run git pull
          output = `cd "#{plugins_dir}" && git pull 2>&1`
          status = $?.exitstatus

          if status == 0
            { success: true, output: output }
          else
            { success: false, error: output }
          end
        rescue => e
          { success: false, error: e.message }
        end
      end

      def self.get_head_commit(plugins_dir)
        begin
          hash = `cd "#{plugins_dir}" && git rev-parse --short HEAD 2>&1`.strip
          return nil unless $?.exitstatus == 0

          author = `cd "#{plugins_dir}" && git log -1 --pretty=format:'%an' 2>&1`.strip
          date = `cd "#{plugins_dir}" && git log -1 --pretty=format:'%ai' 2>&1`.strip
          message = `cd "#{plugins_dir}" && git log -1 --pretty=format:'%s' 2>&1`.strip

          {
            hash: hash,
            author: author,
            date: date,
            message: message
          }
        rescue => e
          nil
        end
      end

      def self.install_plugins(plugins_dir)
        begin
          marketplace_file = File.join(plugins_dir, '.claude-plugin', 'marketplace.json')

          unless File.exist?(marketplace_file)
            return { success: false, message: 'marketplace.json not found' }
          end

          # Read marketplace.json and extract plugin names
          marketplace_content = File.read(marketplace_file)
          plugins = extract_plugin_names(marketplace_content)

          if plugins.empty?
            return { success: true, message: 'No plugins found in marketplace.json' }
          end

          # Install each plugin
          installed = []
          failed = []

          plugins.each do |plugin_name|
            output = `claude plugin install "#{plugin_name}" 2>&1`
            if $?.exitstatus == 0
              installed << plugin_name
            else
              failed << "#{plugin_name}: #{output}"
            end
          end

          message = "Installed: #{installed.join(', ')}"
          message += "\nFailed: #{failed.join(', ')}" if failed.any?

          {
            success: failed.empty?,
            message: message
          }
        rescue => e
          { success: false, message: "Error: #{e.message}" }
        end
      end

      def self.extract_plugin_names(json_content)
        begin
          # Use simple regex to extract plugin names from JSON
          # Looking for "name": "plugin_name" entries
          plugin_names = []
          json_content.scan(/"name"\s*:\s*"([^"]+)"/) do |match|
            plugin_names << match[0]
          end
          # Remove duplicates (first match is usually the marketplace name itself)
          plugin_names.uniq.drop(1)
        rescue => e
          []
        end
      end
    end
  end
end
