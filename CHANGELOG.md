# Changelog

## 0.29.0
### Improvements
- Added new command `claude-plugins setup`
### Bugfixes
- Fixes of message processing 2 times

## 0.28.2
### Bugfixes
- Fixes of message processing

## 0.28.1
### Bugfixes
- `claude plugin sync` changed to `claude-plugins sync`

## 0.28.0
### Improvements
- Adding internal Slack mcp for support

## 0.27.2
### Bugfixes
- Tuning of processing not human messages

## 0.27.1
### Bugfixes
- Tuning of processing not human messages

## 0.27.0
### Improvements
- Bot should react on messages from automation if it tagged directly.
### Bugfixes
- Fixed `take a look` command to properly work with files

## 0.26.2
### Bugfixes
- PDF download fixes

## 0.26.1
### Bugfixes
- PDF download fixes

## 0.26.0
### Improvements
- Isolated folder for threads
- Support if media in thread
### Bugfixes
- Prompt is too long

## 0.25.1
### Bugfixes
- Prompt is too long

## 0.25.0
### Improvements
- Adding command `claude` and support parameters.
- Fixing claude execution params under `take a look` cmd.

## 0.24.1
### Improvements
- Add CLAUDE.md with project documentation and development commands
- Add kramdown and kramdown-parser-gfm gems for markdown parsing
- Create SlackMarkdownHelper with markdown_to_slack method
- Convert markdown to Slack mrkdwn format (bold, italic, lists, code, links)
- Add test coverage for basic markdown conversions

## 0.24.0
### Improvements
- Adding commit id in docker image for non master branch builds
- Added command to sync claude plugins repo and install all
- Added command to create custom prompt for channel

## 0.23.0
### Improvements
- Added Claude agent inside with support of
  - Custom plugins repo
  - MCPS:Jenkins/Confluence/Jira/Bitbucket/Slack

## 0.22.2
### Improvements
- Added new command `configure jira issue defaults` to setup payload for project where to create jira tasks from thread

## 0.22.1
### Bugfixes
- Jira ticket creation from Slack thread fixes

## 0.22.0
### Improvements
- Added feature create Jira ticket from Slack thread

## 0.21.6
### Improvements
- Improving release flow on github actions

## 0.21.5
### Improvements
- Improving release flow on github actions

## 0.21.4
### Improvements
- Improving release flow on github actions

## 0.21.3
### Improvements
- Improving release flow on github actions

## 0.21.2
### Improvements
- Improving release flow on github actions

## 0.21.1
### Improvements
- Improving release flow on github actions

## 0.21.0
### Improvements
- Claude integration added
- Slack Socket mode optimisations

## 0.20.3
### Bugfixes
- Fixing hack to remove limit for async-websocket 0.8.0

## 0.20.2
### Bugfixes
- Added hack to remove limit for async-websocket 0.8.0

## 0.20.1
### Bugfixes
- Rollback async-websocket 0.8.0

## 0.20.0
### Improvements
- Migration to Slack Socket mode

## 0.19.7
### Bugfixes
- Fixed saving messaged for reminder
- Fixed duty create

## 0.19.6
### Bugfixes
- Fixed reminder feature

## 0.19.5
### Bugfixes
- Fixed hider reason disable feature

## 0.19.4
### Bugfixes
- Fixing hide reason feature
- Code cleanup
- Fixing answer at non-working hours and working hours
- Fixing problems actions with nil values

## 0.19.3
### Bugfixes
- Deleted not used code

## 0.19.2
### Bugfixes
- Fixed creation of duty for other users.
- Improved error handling.

## 0.19.1
### Bugfixes
- Fixed issue with new lines `\n` in custom answer.

## 0.19.0
### Improvements
- Improved help description
- Updated documentation
- Code refactoring

## 0.18.3
### Bugfixes
- Reminder fixes
- Help documentation fixes

## 0.18.2
### Bugfixes
- Fixing version display in help

## 0.18.1
### Bugfixes
- DB migration fixes

## 0.18.0
### Improvements
- Added command to display known problems for channel  [#169](/../../issues/169)
- Added command to display solution for substring of known problem   [#169](/../../issues/169)

## 0.17.1
### Bugfixes
- DB migration fixes

## 0.17.0
### Improvements
- Security updates of dependencies
- Added feature to enable bot answer at working time [#192](/../../issues/192)
- Added feature to tag reporter in thread
- OpsGenie code moved to lib folder
- MessageProcessor moved to lib folder
- Commands help refactored

## 0.16.3
### Bugfixes
- Fixes memory leak in sync git repos

## 0.16.2
### Bugfixes
- Fixes in skip logic

## 0.16.1
### Bugfixes
- Date fixes

## 0.16.0
### Improvements
- Added more logic around skipping repos without new changes

## 0.15.0
### Improvements
- Added skip repo sync if last import was less 1 day ago

## 0.14.2
### Bugfixes
- Deleted hardcoded params

## 0.14.1
### Bugfixes
- Deleted wrong name in response

## 0.14.0
### Improvements
- Added multithreading for sync git repos
- Added pull request commits discovery
- Added additional logging for sync git repos

## 0.13.2
### Improvements
- Increased limit for elements

## 0.13.1
### Improvements
- Fixes in sync git repos

## 0.13.0
### Improvements
- Better logging of sync git repos
- Added sync of non default branches

## 0.12.1
### Bugfixes
- Layout and constraint fixes

## 0.12.0
### Features
- Added new action `git commits` - it will return last 10 user commits

## 0.11.0
### Features
- Added Bitbucket Datacenter commits report feature

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
