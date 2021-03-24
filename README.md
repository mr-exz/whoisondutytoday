# Slack bot Whoisondutytoday

## Description
This bot allow you configure working time in Slack channels.\
And if somebody will write at non working hours, bot will reply on message,\
with escalation option.

[Changelog](./CHANGELOG.md)

## Features
- Call duty person over Opsgenie service.
- User can enable themselves in channel as a duty person.
- Users in channel can ask bot who is on duty?
- User can tell to bot create/update/delete his (user) duty schedule in channel.
- User can set own status lunch/work/holidays.
- In non working time bot will reply on all messages in channel with option escalate it.
- Bot have internal Web UI: 127.0.0.1:3000.
- Web page list of duties in channels with delete option.
- Web page list of users.
- Web page list of replied messages.

## Bot commands
```
Commands in channel:
-- call duty person - will send alert message to duty person.
-- i am on duty - will set you as duty person in channel.
-- who is on duty? - will display name of duty persion.
-- channel reminder enabled - will enable reminder for not answered messages in channel.
-- channel reminder disabled - will disable reminder for not answered messages in channel.
-- duty create - will create duty, example duty create from 8:00 to 17:00.
-- duty update - will update duty, example duty update from 8:00 to 17:00.
-- duty delete - will delete duty.
-- duty sync with opsgenie schedule - will configure all duties in channel with schedule name from Opsgenie, example duty sync with opsgenie schedule My_Team_Schedule.
-- duty set opsgenie escalation - will configure all duties in channel with escalation name from Opsgenie, example duty set opsgenie escalation My_Team_Escalation.
-- answer set custom text - configure custom text in answers from bot, example answer set custom text nobody will help you, wait for next day.
-- answer delete custom text - delete custom text answer, use default.
Commands in dirrect messages:
-- my status lunch - set status on lunch.
-- my status work - set status on duty.
-- my status holidays - set status on holidays.
```

## How to start

```bash
git clone https://github.com/mr-exz/whoisondutytoday.git
cd ./whoisondutytoday
mkdir -p /opt/whoisondutytoday/db/data
```

Copy file and define valid Slack API API Token. Create bot [here](https://slack.com/intl/en-hr/help/articles/115005265703-create-a-bot-for-your-workspace).

```bash
cp ./production.env.example ./production.env
```

```bash
docker-compose build
docker-compose up
```

