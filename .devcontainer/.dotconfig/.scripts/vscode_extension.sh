#!/bin/sh

DIR=`dirname $0`
CONFIG="${DIR}/vscode_extension.txt"

# VS Code remote-cli の code コマンドをスタブより優先させる
CODE_PATH=$(find /vscode/vscode-server -name "code" -path "*/remote-cli/code" 2>/dev/null | head -1)
if [ -n "$CODE_PATH" ]; then
    export PATH="$(dirname $CODE_PATH):$PATH"
fi

# VSCODE_IPC_HOOK_CLI が未設定の場合、実行中のプロセスから探す
if [ -z "$VSCODE_IPC_HOOK_CLI" ]; then
    for env_file in /proc/*/environ; do
        val=$(cat "$env_file" 2>/dev/null | tr '\0' '\n' | grep '^VSCODE_IPC_HOOK_CLI=')
        if [ -n "$val" ]; then
            VSCODE_IPC_HOOK_CLI=$(echo "$val" | cut -d= -f2-)
            export VSCODE_IPC_HOOK_CLI
            break
        fi
    done
fi

MARKER="$HOME/.vscode_extensions_installed"
if [ -f "$MARKER" ]; then
    echo "VS Code extensions already installed, skipping."
    exit 0
fi

for l in `cat ${CONFIG}`;do
    code --install-extension ${l}
done

touch "$MARKER"