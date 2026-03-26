#!/bin/sh

# WSLg の PulseAudio TCP モジュールを有効化する
# Ubuntu WSL 上で実行する: sh .devcontainer/setup-wslg-audio.sh

# 現在のセッションに読み込む
pactl load-module module-native-protocol-tcp \
    auth-ip-acl="127.0.0.1;172.0.0.0/8;10.0.0.0/8" \
    auth-anonymous=1 2>/dev/null \
    && echo "Module loaded." \
    || echo "Already loaded (or error)."

# WSL 再起動後も自動で読み込む設定を ~/.bashrc に追加
if ! grep -q 'module-native-protocol-tcp' ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# WSLg PulseAudio TCP
pactl load-module module-native-protocol-tcp auth-ip-acl="127.0.0.1;172.0.0.0/8;10.0.0.0/8" auth-anonymous=1 >/dev/null 2>&1 || true
EOF
    echo "Added to ~/.bashrc."
else
    echo "Already configured in ~/.bashrc."
fi
