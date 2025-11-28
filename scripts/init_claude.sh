#!/bin/bash

set -e

# Configuration
PLUGINS_DIR="${PLUGINS_DIR:-/opt/app/plugins}"
WORKSPACE_DIR="${WORKSPACE_DIR:-/opt/app/workspace}"

APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check if variable is defined
check_var() {
  local var_name=$1
  local var_value=$2

  if [ -z "$var_value" ]; then
    echo "⚠ Missing: $var_name"
  else
    echo "✓ $var_name set"
  fi
}

# Validate environment variables
validate_env_vars() {
  echo "=== Environment Variables Validation ==="

  check_var "ANTHROPIC_AUTH_TOKEN" "$ANTHROPIC_AUTH_TOKEN"
  check_var "BITBUCKET_HOST" "$BITBUCKET_HOST"
  check_var "BITBUCKET_API_TOKEN" "$BITBUCKET_API_TOKEN"
  check_var "JIRA_BASE_URL" "$JIRA_BASE_URL"
  check_var "JIRA_PAT" "$JIRA_PAT"
  check_var "CONFLUENCE_BASE_URL" "$CONFLUENCE_BASE_URL"
  check_var "CONFLUENCE_PAT" "$CONFLUENCE_PAT"
  check_var "JENKINS_1_BASE_URL" "$JENKINS_1_BASE_URL"
  check_var "JENKINS_1_USERNAME" "$JENKINS_1_USERNAME"
  check_var "JENKINS_1_TOKEN" "$JENKINS_1_TOKEN"
  check_var "JENKINS_2_BASE_URL" "$JENKINS_2_BASE_URL"
  check_var "JENKINS_2_USERNAME" "$JENKINS_2_USERNAME"
  check_var "JENKINS_2_TOKEN" "$JENKINS_2_TOKEN"
  check_var "BITBUCKET_USERNAME" "$BITBUCKET_USERNAME"
  check_var "BITBUCKET_PASSWORD" "$BITBUCKET_PASSWORD"
  check_var "BITBUCKET_URL" "$BITBUCKET_URL"
  check_var "SLACK_MCP_URL" "$SLACK_MCP_URL"
  check_var "SLACK_MCP_API_KEY" "$SLACK_MCP_API_KEY"
  check_var "SLACK_MCP_XOXP_TOKEN" "$SLACK_MCP_XOXP_TOKEN"
  check_var "PLUGIN_REPO_URL" "$PLUGIN_REPO_URL"
  check_var "PLUGIN_REPO_USERNAME" "$PLUGIN_REPO_USERNAME"
  check_var "PLUGIN_REPO_PASSWORD" "$PLUGIN_REPO_PASSWORD"

  echo "===================================="
  echo ""
}

# Initialize Claude config from template
init_claude_config() {
  local template_file="$APP_ROOT/scripts/claude-settings-template.json"
  local config_file="$HOME/.claude/settings.json"

  mkdir -p "$HOME/.claude"

  # Replace placeholders with environment variables
  if [ -f "$template_file" ]; then
    sed -e "s|{{ANTHROPIC_BASE_URL}}|${ANTHROPIC_BASE_URL:-https://api.anthropic.com}|g" \
        -e "s|{{ANTHROPIC_AUTH_TOKEN}}|${ANTHROPIC_AUTH_TOKEN}|g" \
        -e "s|{{ANTHROPIC_DEFAULT_HAIKU_MODEL}}|${ANTHROPIC_DEFAULT_HAIKU_MODEL}|g" \
        -e "s|{{ANTHROPIC_DEFAULT_SONNET_MODEL}}|${ANTHROPIC_DEFAULT_SONNET_MODEL}|g" \
        "$template_file" > "$config_file"
    chmod 600 "$config_file"
    echo "✓ Claude settings initialized at $config_file"
  else
    echo "✗ Template file not found: $template_file"
    exit 1
  fi
}

# Setup Bitbucket MCP
setup_bitbucket_mcp() {
  if [ -n "$BITBUCKET_HOST" ] && [ -n "$BITBUCKET_API_TOKEN" ]; then
    if claude mcp add mcp-atlassian-bitbucket --scope user \
      --env "BITBUCKET_API_BASE_PATH=https://${BITBUCKET_HOST}/rest" \
      --env "BITBUCKET_API_TOKEN=${BITBUCKET_API_TOKEN}" \
      -- npx -y @atlassian-mcp-server/bitbucket > /dev/null 2>&1; then
      echo "✓ Bitbucket MCP added"
    else
      echo "⚠ Bitbucket MCP setup skipped or failed"
    fi
  fi
}

# Setup Jira MCP
setup_jira_mcp() {
  if [ -n "$JIRA_BASE_URL" ] && [ -n "$JIRA_PAT" ]; then
    if claude mcp add mcp-atlassian-jira --scope user \
      --env "JIRA_API_BASE_PATH=${JIRA_BASE_URL}/rest" \
      --env "JIRA_API_TOKEN=${JIRA_PAT}" \
      -- npx -y @atlassian-dc-mcp/jira > /dev/null 2>&1; then
      echo "✓ Jira MCP added"
    else
      echo "⚠ Jira MCP setup skipped or failed"
    fi
  fi
}

# Setup Confluence MCP
setup_confluence_mcp() {
  if [ -n "$CONFLUENCE_BASE_URL" ] && [ -n "$CONFLUENCE_PAT" ]; then
    if claude mcp add mcp-atlassian-confluence --scope user \
      --env "CONFLUENCE_API_BASE_PATH=${CONFLUENCE_BASE_URL}" \
      --env "CONFLUENCE_API_TOKEN=${CONFLUENCE_PAT}" \
      -- npx -y @atlassian-dc-mcp/confluence > /dev/null 2>&1; then
      echo "✓ Confluence MCP added"
    else
      echo "⚠ Confluence MCP setup skipped or failed"
    fi
  fi
}

# Setup Slack MCP
setup_slack_mcp() {
  if [ -n "$SLACK_MCP_URL" ] && [ -n "$SLACK_MCP_API_KEY" ]; then
    if claude mcp add --transport http slack --scope user "${SLACK_MCP_URL}" --header "Authorization: Bearer ${SLACK_MCP_API_KEY}" > /dev/null 2>&1; then
      echo "✓ Slack MCP added"
    else
      echo "⚠ Slack MCP setup skipped or failed"
    fi
  elif [ -n "$SLACK_MCP_XOXP_TOKEN" ]; then
    if claude mcp add slack --scope user --env "SLACK_MCP_XOXP_TOKEN=${SLACK_MCP_XOXP_TOKEN}" -- npx -y slack-mcp-server@latest --transport stdio > /dev/null 2>&1; then
      echo "✓ Slack MCP added (legacy)"
    else
      echo "⚠ Slack MCP setup skipped or failed"
    fi
  fi
}

# Setup Jenkins MCPs
setup_jenkins_mcps() {
  # Jenkins 1
  if [ -n "$JENKINS_1_BASE_URL" ] && [ -n "$JENKINS_1_USERNAME" ] && [ -n "$JENKINS_1_TOKEN" ]; then
    local jenkins_1_auth=$(echo -n "${JENKINS_1_USERNAME}:${JENKINS_1_TOKEN}" | base64 -w 0)
    if claude mcp add --transport http jenkins-1 --scope user "${JENKINS_1_BASE_URL}/mcp-server/mcp" --header "Authorization: Basic ${jenkins_1_auth}" > /dev/null 2>&1; then
      echo "✓ Jenkins 1 MCP added"
    else
      echo "⚠ Jenkins 1 MCP setup skipped or failed"
    fi
  fi

  # Jenkins 2
  if [ -n "$JENKINS_2_BASE_URL" ] && [ -n "$JENKINS_2_USERNAME" ] && [ -n "$JENKINS_2_TOKEN" ]; then
    local jenkins_2_auth=$(echo -n "${JENKINS_2_USERNAME}:${JENKINS_2_TOKEN}" | base64 -w 0)
    if claude mcp add --transport http jenkins-2 --scope user "${JENKINS_2_BASE_URL}/mcp-server/mcp" --header "Authorization: Basic ${jenkins_2_auth}" > /dev/null 2>&1; then
      echo "✓ Jenkins 2 MCP added"
    else
      echo "⚠ Jenkins 2 MCP setup skipped or failed"
    fi
  fi
}

# Clone or update plugin repository and install
setup_plugins() {
  if [ -z "$PLUGIN_REPO_URL" ]; then
    echo "⚠ PLUGIN_REPO_URL not set, skipping plugin setup"
    return 0
  fi

  local repo_url="$PLUGIN_REPO_URL"

  # Configure git credentials for plugin repository if provided
  if [ -n "$PLUGIN_REPO_USERNAME" ] && [ -n "$PLUGIN_REPO_PASSWORD" ]; then
    git config --global credential.helper store

    # Extract host from URL for git credentials
    local repo_host=$(echo "$repo_url" | sed -E 's|https?://||' | cut -d'/' -f1)

    # Add plugin repo credentials to git credentials
    echo "https://${PLUGIN_REPO_USERNAME}:${PLUGIN_REPO_PASSWORD}@${repo_host}" >> ~/.git-credentials 2>/dev/null || true
    chmod 600 ~/.git-credentials 2>/dev/null || true
  fi

  # Clone or update plugins repository
  if [ ! -d "$PLUGINS_DIR/.git" ]; then
    echo "Cloning plugin repository: $repo_url"
    git clone "$repo_url" "$PLUGINS_DIR" || {
      echo "⚠ Failed to clone plugin repository"
      return 0
    }
  else
    echo "Updating plugin repository..."
    cd "$PLUGINS_DIR" && git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
  fi

  # Add plugin marketplace to Claude Code
  if [ -d "$PLUGINS_DIR" ]; then
    claude plugin marketplace add "$PLUGINS_DIR" || true
    echo "✓ Plugin marketplace added"

    # Install all available plugins from the marketplace
    if [ -f "$PLUGINS_DIR/.claude-plugin/marketplace.json" ]; then
      # Extract plugin names from the plugins array
      local plugins=$(grep -A 100 '"plugins"' "$PLUGINS_DIR/.claude-plugin/marketplace.json" | grep -o '"name": "[^"]*"' | cut -d'"' -f4 | head -20)
      for plugin in $plugins; do
        claude plugin install "$plugin" || true
      done
      echo "✓ Plugins installed from marketplace"
    fi
  fi
}

# Main execution
main() {
  echo ""
  echo "=========================================="
  echo "Claude Initialization Script"
  echo "=========================================="
  echo ""

  # Validate environment variables first
  validate_env_vars

  # Initialize Claude config (Claude settings only)
  echo "=== Initializing Claude Config ==="
  init_claude_config
  echo ""

  # Setup all MCPs
  echo "=== Setting up MCPs ==="
  setup_bitbucket_mcp
  setup_jira_mcp
  setup_confluence_mcp
  setup_slack_mcp
  setup_jenkins_mcps
  echo ""

  # Setup plugins
  echo "=== Setting up Plugins ==="
  setup_plugins
  echo ""

  echo "=========================================="
  echo "✓ Claude initialization complete"
  echo "=========================================="
  echo ""
}

# Run main if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
