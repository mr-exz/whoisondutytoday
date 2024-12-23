# Slack bot Whoisondutytoday

## Description
This bot allow you configure working time in Slack channels.\
And if somebody will write at non working hours, bot will reply on message,\
with escalation option.

* [Changelog](./CHANGELOG.md)
* [Docker](https://hub.docker.com/r/mrexz/whoisondutytoday)
* ![Build](https://github.com/mr-exz/whoisondutytoday/actions/workflows/docker-build.yml/badge.svg)
* ![Known Vulnerabilities](https://snyk.io/test/github/mr-exz/whoisondutytoday/badge.svg)


## Features


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
```

```bash
docker-compose build
docker-compose up
```

