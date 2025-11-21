#!/bin/bash

set -e

PLUGINS_DIR="${PLUGINS_DIR:-/opt/app/plugins}"

# Check if directory exists
if [ ! -d "$PLUGINS_DIR" ]; then
  echo "ERROR: Plugin directory not found: $PLUGINS_DIR"
  exit 1
fi

# Check if it's a git repo
if [ ! -d "$PLUGINS_DIR/.git" ]; then
  echo "ERROR: Not a git repository: $PLUGINS_DIR"
  exit 1
fi

# Get commit before pull
COMMIT_BEFORE=$(cd "$PLUGINS_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "")

# Pull latest changes
cd "$PLUGINS_DIR" && git pull > /dev/null 2>&1

# Get commit after pull
COMMIT_AFTER=$(cd "$PLUGINS_DIR" && git rev-parse --short HEAD 2>/dev/null)
AUTHOR=$(cd "$PLUGINS_DIR" && git log -1 --pretty=format:%an 2>/dev/null)
DATE=$(cd "$PLUGINS_DIR" && git log -1 --pretty=format:%ai 2>/dev/null)
MESSAGE=$(cd "$PLUGINS_DIR" && git log -1 --pretty=format:%s 2>/dev/null)

# Check if updated
if [ "$COMMIT_BEFORE" != "$COMMIT_AFTER" ]; then
  UPDATED="true"
else
  UPDATED="false"
fi

# Output as JSON for easy parsing
cat <<EOF
{
  "success": true,
  "updated": $UPDATED,
  "hash": "$COMMIT_AFTER",
  "author": "$AUTHOR",
  "date": "$DATE",
  "message": "$MESSAGE"
}
EOF
