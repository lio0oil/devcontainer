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

# Gemini CLI
if [ "$INSTALL_GEMINI_CLI" = "true" ]; then
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    npm install -g @google/gemini-cli
    # ~/.gemini/settings.json に mcpServers をマージ
    mkdir -p "$HOME/.gemini"
    GEMINI_SETTINGS="$HOME/.gemini/settings.json"
    # Gemini CLI は disabled / autoApprove キーに非対応のため除去し、disabled:true のエントリは除外する
    GEMINI_MCP=$(jq '{mcpServers: (.mcpServers | to_entries | map(select(.value.disabled != true)) | map(.value |= del(.disabled, .autoApprove)) | from_entries)}' "$MCP_SOURCE")
    if [ -f "$GEMINI_SETTINGS" ]; then
        jq -s '.[0] * .[1]' "$GEMINI_SETTINGS" <(echo "$GEMINI_MCP") > /tmp/gemini_settings.json
        mv /tmp/gemini_settings.json "$GEMINI_SETTINGS"
    else
        echo "$GEMINI_MCP" > "$GEMINI_SETTINGS"
    fi
else
    echo "Skip Gemini CLI installation."
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
