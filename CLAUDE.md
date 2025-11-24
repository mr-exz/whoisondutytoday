# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby on Rails Slack bot that manages on-duty schedules and support channel interactions. The bot runs alongside a Rails web application in the same process (via config.ru), with the bot running in a separate thread.

## Technology Stack

- Ruby 3.3.6
- Rails 7.0.8
- SQLite3 database
- slack-ruby-bot for Slack integration
- async-websocket for WebSocket connections
- Docker for deployment

## Development Commands

### Running the Application
```bash
# Using Docker (recommended)
docker-compose build
docker-compose up

# Local development (ensure Ruby 3.3.6 is installed)
bundle install
bundle exec rails db:migrate
bundle exec rails server
```

### Testing
```bash
bundle exec rake test
```

### Code Quality
```bash
bundle exec rubocop              # Run RuboCop linter
bundle exec standardrb          # Run StandardRB formatter
```

### Database
```bash
bundle exec rails db:migrate     # Run migrations
bundle exec rails db:schema:load # Load schema
bundle exec rails db:rollback    # Rollback last migration
```

### Scheduled Tasks (Rake Tasks)
```bash
bundle exec rake reminder:remind                    # Send reminders for unanswered messages
bundle exec rake opsgenie:sync_duty_for_channels   # Sync duty schedules with Opsgenie
bundle exec rake bitbucket:sync_commits            # Sync commits from Bitbucket
```

### Docker Build & Deploy
```bash
make build        # Build Docker image
make tag-latest   # Tag as latest (master branch only)
make push         # Push to Docker registry
make all          # Build, tag, and push
```

## Architecture

### Bot Architecture

The application has two main components running concurrently:

1. **Rails Application** (`app/`): Provides web interface and database access
2. **Slack Bot** (`bot/`): Handles Slack events and commands

The bot uses a custom WebSocket implementation (`SlackSocket::Client` in `bot/slacksocket.rb`) that:
- Connects to Slack Socket Mode API
- Maintains connection with automatic reconnection logic
- Prevents duplicate message processing using `@processed_messages` hash with TTL
- Routes events to command handlers

### Command Structure

Commands are defined in `bot/whoisondutytodayslackbot.rb` and implemented in `bot/commands/`:
- Each command is a separate module under `WhoIsOnDutyTodaySlackBotModule::Commands`
- Commands receive `client`, `data`, and optionally `match` parameters
- The `scan(/(.*)/)` pattern in the main bot file captures all messages for the `Other` command, which handles:
  - Auto-replies based on duty status
  - Message tracking for reminder system
  - AI-powered responses (via Claude API)

### Key Models

- **Duty**: On-duty schedules with time ranges, days, and Opsgenie integration
- **Channel**: Slack channel configuration with JSON settings for features like:
  - `reminder_enabled`: Enable reminders for unanswered threads
  - `auto_answer_enabled`: Enable automatic bot responses
  - `tag_reporter_enabled`: Tag thread creators in responses
- **Message**: Tracks messages requiring reminders
- **Answer**: Custom text responses per channel
- **Action**: Problem-action mappings for common issues
- **SlackThread** / **Label**: Thread labeling system for categorization
- **BitbucketCommit**: Cached commit data for user activity tracking
- **JiraIssueDefault**: Default field values for JIRA issue creation per project

### External Integrations

Integration code is in `lib/`:
- **Opsgenie** (`lib/opsgenie/`): Schedule syncing for duty management
- **Bitbucket** (`lib/bitbucket/`): Fetch user commits for activity tracking
- **Claude/Anthropic** (`lib/claude/`): AI-powered message summarization and responses
- **JIRA** (`lib/jira/`): Create JIRA issues from Slack threads

All integrations require environment variables (see `production.env.example`).

### Message Processing Flow

1. Slack event arrives via WebSocket connection
2. `handle_message` in `bot/slacksocket.rb` acknowledges and deduplicates
3. Event routed to `WhoIsOnDutyTodaySlackBot.process_event`
4. Commands matched against registered patterns
5. Appropriate command handler invoked
6. For unmatched messages, the `Other` command handles:
   - Duty status checking
   - Auto-answer logic with AI integration
   - Message tracking for reminders

## Configuration

### Required Environment Variables

See `production.env.example` for all required variables:
- `SLACK_API_TOKEN`: Slack App API token
- `SLACK_SOCKETS_TOKEN`: Slack Socket Mode token
- `SLACK_BOT_TOKEN`: Bot User OAuth token
- `OPSGENIE_API_TOKEN`: Opsgenie API integration
- `BITBUCKET_URL`, `BITBUCKET_USERNAME`, `BITBUCKET_PASSWORD`: Bitbucket access
- `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_DEFAULT_SONNET_MODEL`: Claude API configuration
- `JIRA_BASE_URL`, `JIRA_API_TOKEN`: JIRA Data Center API access

### Scheduled Jobs

The bot uses `whenever` gem for cron-like scheduling. Check `config/schedule.rb` for configured jobs.

## Testing

Tests are in `test/` directory with standard Rails structure:
- `test/models/`: Model tests
- `test/controllers/`: Controller tests
- `test/fixtures/`: Test data

Run individual tests:
```bash
bundle exec ruby -Itest test/models/duty_test.rb
```

## Docker Environment

The bot is designed to run in Docker (see `Dockerfile` and `docker-compose.yml`):
- Uses Colima for Docker on macOS
- Database persists in `/opt/whoisondutytoday/db/data`
- Logs to stdout for container logging

## Important Notes

- The bot maintains a single WebSocket connection and automatically reconnects on failure with exponential backoff
- Message deduplication uses `client_msg_id` to prevent processing duplicates during reconnections
- Auto-answer functionality can integrate with Claude AI for intelligent responses based on channel-specific prompts
- The reminder system runs via rake task (typically cron) and DMs duty users about unanswered threads
- Thread labeling system allows categorizing support threads for later analysis