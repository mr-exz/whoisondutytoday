# Slack bot Whoisondutytoday

## Description
This bot allow you configure working time in Slack channels. 
And if somebody will write at non working hours, bot will reply on message.

## Features

* Configure working hours in Slack channel per duty person. (Only one person on duty can be active in channel)
* Set lunch time for duty person.
* Call duty person if it non working hours. 

## Bot commands

```
@botname help
Version: 0.2.0
Commands in channel:
• call duty person - will send alert message to duty person.
• i am on duty - will set you as duty person in channel.
• who is on duty? - will display name of duty persion.
• duty create - will create duty, example duty create from 8:00 to 17:00
• duty update - will update duty, example duty update from 8:00 to 17:00
• duty delete - will delete duty`
Commands in private:
• my status lunch - set status on lunch
• my status work - set status on duty
```

## How to run
```bash
docker-compose up
```

## How to build

```bash
docker-compose build
```

## How to develop

* https://github.com/slack-ruby/slack-ruby-client#get-channel-info

