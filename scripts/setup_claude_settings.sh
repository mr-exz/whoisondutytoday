#!/bin/bash

set -e

TEMPLATE_FILE="${1:-$(dirname "$0")/claude-settings-template.json}"
OUTPUT_DIR="${2:-$HOME/.claude}"
OUTPUT_FILE="$OUTPUT_DIR/settings.json"

echo "=== Setting up Claude settings ==="

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "ERROR: Template file not found: $TEMPLATE_FILE"
    exit 1
fi

echo "Using template: $TEMPLATE_FILE"
echo "Output directory: $OUTPUT_DIR"

# Read template and process placeholders
SETTINGS=$(cat "$TEMPLATE_FILE")

# Replace {{VAR}} with environment variable values
# Uses parameter expansion to provide defaults or error if not set

SETTINGS="${SETTINGS//\{\{ANTHROPIC_BASE_URL\}\}/${ANTHROPIC_BASE_URL:-https://api.anthropic.com}}"
SETTINGS="${SETTINGS//\{\{ANTHROPIC_AUTH_TOKEN\}\}/${ANTHROPIC_AUTH_TOKEN:-}}"
SETTINGS="${SETTINGS//\{\{ANTHROPIC_DEFAULT_HAIKU_MODEL\}\}/${ANTHROPIC_DEFAULT_HAIKU_MODEL:-claude-3-5-haiku-20241022}}"
SETTINGS="${SETTINGS//\{\{ANTHROPIC_DEFAULT_SONNET_MODEL\}\}/${ANTHROPIC_DEFAULT_SONNET_MODEL:-claude-sonnet-4-5-20250929}}"

# Verify auth token is set
if [ -z "$ANTHROPIC_AUTH_TOKEN" ]; then
    echo "WARNING: ANTHROPIC_AUTH_TOKEN not set. Claude will not authenticate."
fi

# Write settings file
echo "$SETTINGS" > "$OUTPUT_FILE"
chmod 600 "$OUTPUT_FILE"

echo "✓ Claude settings written to: $OUTPUT_FILE"

# Verify JSON validity
if command -v jq &> /dev/null; then
    if jq empty "$OUTPUT_FILE" 2>/dev/null; then
        echo "✓ Settings JSON is valid"
    else
        echo "ERROR: Settings JSON is invalid"
        exit 1
    fi
else
    echo "Note: jq not available for JSON validation"
fi

# Show non-sensitive parts of config
echo ""
echo "Claude configuration summary:"
echo "  ANTHROPIC_BASE_URL: ${ANTHROPIC_BASE_URL:-https://api.anthropic.com}"
echo "  ANTHROPIC_DEFAULT_HAIKU_MODEL: ${ANTHROPIC_DEFAULT_HAIKU_MODEL:-claude-3-5-haiku-20241022}"
echo "  ANTHROPIC_DEFAULT_SONNET_MODEL: ${ANTHROPIC_DEFAULT_SONNET_MODEL:-claude-sonnet-4-5-20250929}"
echo "  Auth token: $([ -z "$ANTHROPIC_AUTH_TOKEN" ] && echo "NOT SET" || echo "***")"

echo ""
echo "=== Claude settings setup complete ==="
