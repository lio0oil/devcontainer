#!/bin/sh

# Windows 上の VS Code から devcontainer を起動し、Voice モードを使う場合のセットアップ
# コンテナは host.docker.internal:4713 経由で WSL2 の PulseAudio に接続する
# Claude Code をインストールした WSL2 ディストリビューション上で実行する:
#   sh .devcontainer/setup-wsl-pulse-tcp.sh

# PulseAudio TCP モジュールを今すぐ有効化
pactl load-module module-native-protocol-tcp auth-anonymous=1 port=4713 2>/dev/null && \
    echo "PulseAudio TCP module loaded." || \
    echo "PulseAudio TCP module already loaded or pactl unavailable."

# WSL2 再起動後も自動で有効になるよう ~/.config/pulse/default.pa に追記
PULSE_CONFIG="$HOME/.config/pulse/default.pa"
mkdir -p "$(dirname "$PULSE_CONFIG")"
if [ ! -f "$PULSE_CONFIG" ]; then
    echo ".include /etc/pulse/default.pa" > "$PULSE_CONFIG"
fi
if ! grep -q "module-native-protocol-tcp" "$PULSE_CONFIG"; then
    echo "load-module module-native-protocol-tcp auth-anonymous=1 port=4713" >> "$PULSE_CONFIG"
    echo "Added TCP module to $PULSE_CONFIG (persistent)."
else
    echo "TCP module already configured in $PULSE_CONFIG."
fi
