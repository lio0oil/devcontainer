#!/bin/sh

cd ~
if [ -d "zsh_plugins/zaw" ]; then
    exit 
fi
if [ ! -d zsh_plugins ]; then
    mkdir zsh_plugins
fi
cd zsh_plugins
git clone https://github.com/zsh-users/zaw.git

cat << "EOF" >> ~/.zshrc
# zaw
source /home/vscode/zsh_plugins/zaw/zaw.zsh
bindkey '^r' zaw-history
EOF