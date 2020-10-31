# Changelog
## 0.3.3
### Improvements 
- Added Opsgenie escalation.

## 0.3.2
### Improvements 
- Docker build optimisation.
- Update translatio.

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
- Syncing duty schedule from Opsgenie [25](https://github.com/mr-exz/whoisondutytoday/issues/25).
### Fixes
- Display working hours in local time of requester [8](https://github.com/mr-exz/whoisondutytoday/issues/8).
- Stop replying on messages in channel from duty person [26](https://github.com/mr-exz/whoisondutytoday/issues/26).

## 0.1.0
### Features
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
