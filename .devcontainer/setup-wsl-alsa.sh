#!/bin/sh

# WSL2 上で直接 Claude Code などを使う場合の ALSA セットアップ
# Claude Code をインストールした WSL2 ディストリビューション上で実行する:
#   sh .devcontainer/setup-wsl-alsa.sh

# ALSA パッケージをインストール
sudo apt-get install -y alsa-utils libasound2-plugins

# ALSA のデフォルトを PulseAudio に向ける
if [ ! -f ~/.asoundrc ]; then
    cat > ~/.asoundrc << 'EOF'
pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}
EOF
    echo "Created ~/.asoundrc."
else
    echo "~/.asoundrc already exists."
fi
