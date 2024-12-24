# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require_relative 'bot/whoisondutytodayslackbot'

Thread.abort_on_exception = true
Thread.new do
  WhoIsOnDutyTodaySlackBot.run
end

run Rails.application
