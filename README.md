# Slack bot Whoisondutytoday

## Description
This is a Slack bot designed to manage and interact with users on support channels. \
It provides various commands to:
* Call the duty person.
* Show and update user on support statuses where it absent.
* Manage duty schedules (create, update, delete, sync with Opsgenie).
* Enable or disable channel-specific features like reminders, auto-answer, and tagging.
* Handle custom text for answers.
* Manage actions and show related problems.
* Clean and display thread labels.
* Show statistics and manage channel labels.
* Display user commits from Bitbucket.
* Remind about threads without replies.

## Links
* [Changelog](./CHANGELOG.md)
* [Docker](https://hub.docker.com/r/mrexz/whoisondutytoday)
* ![Build](https://github.com/mr-exz/whoisondutytoday/actions/workflows/docker-build.yml/badge.svg)
* ![Known Vulnerabilities](https://snyk.io/test/github/mr-exz/whoisondutytoday/badge.svg)

## Bot commands
```
@bot help
```

## How to start

```bash
git clone https://github.com/mr-exz/whoisondutytoday.git
cd ./whoisondutytoday
mkdir -p /opt/whoisondutytoday/db/data
```

Copy file and define variables. Create bot [here](https://slack.com/intl/en-hr/help/articles/115005265703-create-a-bot-for-your-workspace).

```bash
cp ./production.env.example ./production.env
docker-compose build
docker-compose up
```

