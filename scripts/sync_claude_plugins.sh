#!/bin/bash

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

# Extract plugin names from marketplace.json
MARKETPLACE_FILE="$PLUGINS_DIR/.claude-plugin/marketplace.json"
PLUGINS=""
if [ -f "$MARKETPLACE_FILE" ]; then
  PLUGINS=$(grep -o '"name": "[^"]*"' "$MARKETPLACE_FILE" | cut -d'"' -f4 | tail -n +2)
fi

# Install plugins and capture output
INSTALL_OUTPUT=""
if [ -n "$PLUGINS" ]; then
  while IFS= read -r plugin; do
    if [ -n "$plugin" ]; then
      OUTPUT=$(claude plugin install "$plugin" 2>&1)
      INSTALL_OUTPUT="$INSTALL_OUTPUT
$OUTPUT"
    fi
  done <<< "$PLUGINS"
fi

# Escape JSON strings
escape_json() {
  local string="$1"
  # Escape backslashes, quotes, newlines, carriage returns, tabs
  string="${string//\\/\\\\}"
  string="${string//\"/\\\"}"
  string="${string//$'\n'/\\n}"
  string="${string//$'\r'/\\r}"
  string="${string//$'\t'/\\t}"
  echo "$string"
}

INSTALL_OUTPUT_ESCAPED=$(escape_json "$INSTALL_OUTPUT")

# Output as JSON for easy parsing
cat <<EOF
{
  "success": true,
  "updated": $UPDATED,
  "hash": "$COMMIT_AFTER",
  "author": "$AUTHOR",
  "date": "$DATE",
  "message": "$MESSAGE",
  "install_output": "$INSTALL_OUTPUT_ESCAPED"
}
EOF
