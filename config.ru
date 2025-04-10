# This file is used by Rack-based servers to start the application.
require_relative 'config/environment'
require_relative 'bot/whoisondutytodayslackbot'

# Thread.abort_on_exception = true

def start_bot
  loop do
    begin
      # Start the bot in a new thread
      bot_thread = Thread.new do
        WhoIsOnDutyTodaySlackBot.run
      end

      # Wait for the thread to finish and handle any exceptions
      bot_thread.join
    rescue EOFError => e
      puts "Bot encountered an EOFError: #{e.message}. Restarting..."
    rescue StandardError => e
      puts "Bot encountered an error: #{e.message}. Restarting..."
    ensure
      # Ensure the thread is terminated before restarting
      bot_thread&.kill
    end

    # Wait before restarting to avoid rapid restarts
    sleep(5)
  end
end

# Start the bot in a separate thread
Thread.new { start_bot }

# Start the Rails application
run Rails.application