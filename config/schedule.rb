set :output, '/var/log/cron.log'
set :environment, 'development'

every 15.minute do
  rake "reminder:remind"
end