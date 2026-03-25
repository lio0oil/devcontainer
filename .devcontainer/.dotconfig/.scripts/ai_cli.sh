#!/bin/sh

DIR=$(dirname $0)
. $DIR/config.sh

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
