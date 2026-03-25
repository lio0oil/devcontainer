#!/bin/sh

DIR=$(dirname $0)
. $DIR/config.sh

# MCP 設定を各 AI CLI の設定ファイルにシンボリックリンクする
# postCreateCommand.sh から呼ばれる際の作業ディレクトリは .devcontainer/
WORKSPACE=$(cd "$(pwd)/.." && pwd)
MCP_SOURCE="$(pwd)/mcp.json"

# Claude Code: .mcp.json（プロジェクトスコープ）
ln -sf "$MCP_SOURCE" "$WORKSPACE/.mcp.json"

# Kiro: .kiro/settings/mcp.json
mkdir -p "$WORKSPACE/.kiro/settings"
ln -sf "$MCP_SOURCE" "$WORKSPACE/.kiro/settings/mcp.json"

# Gemini CLI: ~/.gemini/settings.json に mcpServers をマージ
mkdir -p "$HOME/.gemini"
GEMINI_SETTINGS="$HOME/.gemini/settings.json"
if [ -f "$GEMINI_SETTINGS" ]; then
    # 既存の設定に mcpServers をマージ（既存の設定を保持）
    jq -s '.[0] * {mcpServers: .[1].mcpServers}' "$GEMINI_SETTINGS" "$MCP_SOURCE" > /tmp/gemini_settings.json
    mv /tmp/gemini_settings.json "$GEMINI_SETTINGS"
else
    cp "$MCP_SOURCE" "$GEMINI_SETTINGS"
fi

# Claude Code
if [ "$INSTALL_CLAUDE_CODE" = "true" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "Skip Claude Code installation."
fi

# Gemini CLI
if [ "$INSTALL_GEMINI_CLI" = "true" ]; then
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    npm install -g @google/gemini-cli
else
    echo "Skip Gemini CLI installation."
fi

# Kiro CLI
if [ "$INSTALL_KIRO_CLI" = "true" ]; then
    curl -fsSL https://cli.kiro.dev/install | bash
else
    echo "Skip Kiro CLI installation."
fi
