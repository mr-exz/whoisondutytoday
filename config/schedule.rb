set :output, '/var/log/cron.log'
set :environment, 'development'

every 15.minute do
  rake "reminder:remind"
end

every 5.minute do
  rake "opsgenie:rotate"
end