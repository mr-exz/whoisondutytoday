# Changelog
## 0.11.0
### Features
- Added Bitbucket commits report feature

## 0.10.4
### Bugfixes
- Gem::LoadError: can't activate sqlite3 (~> 1.4), already activated sqlite3-2.2.0-x86_64-linux-gnu.

## 0.10.3
### Improvements
- Update ruby up to `3.3.6`

## 0.10.2 
### Improvements
- Dependencies updates

## 0.10.1
### Improvements
- Deleting no needed code
- Improved statistic output.
- Added `channel labels merge`

## 0.10.0
### Improvements
- Added MIT license
- Updated dependencies
- Removed vagrant files
- Added labels feature for threads and show statistic for last 9 weeks
- Changed user status to custom

## 0.9.0
### Bugfixes
- OpsGenie rake task fixes
- Updated version in Gemfile
### Improvements
- Known-problem reply feature doesn't trigger if problem is in a code block [#134](/../../issues/134)
- No non-working-hours message if known-problem reply triggered [#135](/../../issues/135) 

## 0.8.1
### Bugfixes
- Small bugfixes

## 0.8.0
### Improvements
- Added option create action in chat with bot [#124](/../../issues/124)

## 0.7.1
### Bugfixes
- Check for nil [#85](/../../issues/85).

## 0.7.0
### Improvements
- Added command hide reason [#113](/../../issues/113).
- Added display custom message [#116](/../../issues/116)
- Added display hours for person on duty [#100](/../../issues/100)
- Added option mark thread as replied [#99](/../../issues/99)
- Added support of winter/summer time. [#70](/../../issues/70)
### Bugfixes
- Check for nil [#85](/../../issues/85).

### Fixes
- Fixed publishing docker image with latest tag.
- Fixed reminder of not answered requests.

## 0.6.8
### Improvements
- Added github flow
- Added Makefile to build project and tag it
- Added versioning from CHANGELOG.md

## 0.6.7
### Improvements
- Added actions table, bot will suggest "actions" on certain "problems"
- Bump addressable,puma,nio4r due to security issues

## 0.6.6
### Improvements 
- Switched to Ruby 2.7.3
- [Rake job to sync person on call from OpsGenie schedule.](https://github.com/mr-exz/whoisondutytoday/issues/55)
- [Improved sync with OpsGenie schedule.](https://github.com/mr-exz/whoisondutytoday/issues/29)

### Fixes
- [Fixed no replies to messages with attachments](https://github.com/mr-exz/whoisondutytoday/issues/56).

## 0.6.5
### Fixes
- Fixing reminder do not remind about events

## 0.6.4
### Fixes
- Fixing answers in threads

## 0.6.3
### Fixes
- Fixed constant replies from bot in thread
- Fixed saving messages with empty message id

## 0.6.2
### Fixes
- Fixed reminder logic for saved messages.
- Dockerfile fixed broken apt-get

## 0.6.1
### Fixes
- Fixed rake execution task.

## 0.6.0
### Fixes
- Fixed bug with missed answers in old threads.
### Features
- Reminder about threads without replies.

## 0.5.0
### Improvements
- Added view web page to see answers.
### Fixes
- Fixed usage of undefined variable.

## 0.4.0
### Improvements
- Working hours now in UTC time in messages, to avoid confusing people.
- Some old code refactored.
### Features
- Added option to set custom text in bot answers.

## 0.3.3
### Improvements 
- Added OpsGenie escalation.

## 0.3.2
### Improvements 
- Docker build optimisation.
- Update translation.

## 0.3.1
### Fixes
- Fixed rotation function.

# Changelog
## 0.3.0
### Improvements 
- Logging switched to info mode.
- Added link on slack message in alert.

## 0.2.1
### Fixes
- Fixed missed variables and translation.

## 0.2.0
### Features
- Syncing duty schedule from OpsGenie [25](https://github.com/mr-exz/whoisondutytoday/issues/25).
### Fixes
- Display working hours in local time of requester [8](https://github.com/mr-exz/whoisondutytoday/issues/8).
- Stop replying on messages in channel from duty person [26](https://github.com/mr-exz/whoisondutytoday/issues/26).

## 0.1.0
### Features
- Call duty person over OpsGenie service.
- User can enable themselves in channel as a duty person.
- Users in channel can ask bot who is on duty?
- User can tell to bot create/update/delete his (user) duty schedule in channel.
- User can set own status lunch/work/holidays.
- In non working time bot will reply on all messages in channel with option escalate it.
- Bot have internal Web UI: 127.0.0.1:3000.
- Web page list of duties in channels with delete option.
- Web page list of users.
- Web page list of replied messages.
