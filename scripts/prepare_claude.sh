#!/bin/bash

set -e

echo "=== Preparing Claude CLI and MCPs ==="

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm is not installed"
    exit 1
fi

echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Update npm to latest
echo "Updating npm..."
npm install -g npm || true

# Install Claude Code CLI
echo "Installing Claude Code CLI..."
npm install -g @anthropic-ai/claude-code || {
    echo "WARNING: Failed to install Claude Code CLI"
}

# Install MCP servers
echo "Installing Bitbucket MCP..."
npm install -g @atlassian-mcp-server/bitbucket || {
    echo "WARNING: Failed to install Bitbucket MCP"
}

echo "Installing JIRA MCP..."
npm install -g @atlassian-dc-mcp/jira || {
    echo "WARNING: Failed to install JIRA MCP"
}

echo "Installing Confluence MCP..."
npm install -g @atlassian-dc-mcp/confluence || {
    echo "WARNING: Failed to install Confluence MCP"
}

echo ""
echo "=== Installation Complete ==="
echo "Verifying installations..."

# Verify Claude Code CLI
if command -v claude &> /dev/null; then
    echo "✓ Claude CLI installed: $(claude --version 2>/dev/null || echo 'unknown version')"
else
    echo "✗ Claude CLI not found in PATH"
fi

# List global npm packages
echo ""
echo "Global npm packages installed:"
npm list -g --depth=0 2>/dev/null | grep -E "@anthropic-ai|@atlassian" || echo "No MCPs found"

echo ""
echo "=== Preparation complete ==="