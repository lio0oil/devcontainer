#!/bin/bash

DIR=$(dirname $0)
. $DIR/config.sh

# postCreateCommand.sh から呼ばれる際の作業ディレクトリは .devcontainer/
MCP_SOURCE="$(pwd)/mcp.json"

# Claude Code
if [ "$INSTALL_CLAUDE_CODE" = "true" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
    # ~/.claude.json に mcpServers をマージ（ユーザースコープ）
    if [ -f "$HOME/.claude.json" ]; then
        jq -s '.[0] * {mcpServers: .[1].mcpServers}' "$HOME/.claude.json" "$MCP_SOURCE" > /tmp/claude_settings.json
        mv /tmp/claude_settings.json "$HOME/.claude.json"
    else
        cp "$MCP_SOURCE" "$HOME/.claude.json"
    fi
else
    echo "Skip Claude Code installation."
fi

# Antigravity CLI
if [ "$INSTALL_ANTIGRAVITY_CLI" = "true" ]; then
    curl -fsSL https://antigravity.google/cli/install.sh | bash
    # ~/.gemini/antigravity-cli/mcp_config.json に mcpServers をマージ
    mkdir -p "$HOME/.gemini/antigravity-cli"
    AGY_SETTINGS="$HOME/.gemini/antigravity-cli/mcp_config.json"
    # Antigravity CLI は disabled / autoApprove キーに非対応のため除去し、disabled:true のエントリは除外する
    AGY_MCP=$(jq '{mcpServers: (.mcpServers | to_entries | map(select(.value.disabled != true)) | map(.value |= del(.disabled, .autoApprove)) | from_entries)}' "$MCP_SOURCE")
    if [ -f "$AGY_SETTINGS" ]; then
        jq -s '.[0] * .[1]' "$AGY_SETTINGS" <(echo "$AGY_MCP") > /tmp/agy_settings.json
        mv /tmp/agy_settings.json "$AGY_SETTINGS"
    else
        echo "$AGY_MCP" > "$AGY_SETTINGS"
    fi
else
    echo "Skip Antigravity CLI installation."
fi

# Kiro CLI
if [ "$INSTALL_KIRO_CLI" = "true" ]; then
    curl -fsSL https://cli.kiro.dev/install | bash
    # ~/.kiro/settings/mcp.json にシンボリックリンクを作成（ユーザースコープ）
    mkdir -p "$HOME/.kiro/settings"
    ln -sf "$MCP_SOURCE" "$HOME/.kiro/settings/mcp.json"
else
    echo "Skip Kiro CLI installation."
fi
