#!/bin/sh

# devcontainers theme
THEME_DEST="$HOME/.oh-my-zsh/custom/themes/devcontainers.zsh-theme"
mkdir -p "$(dirname $THEME_DEST)"
curl -fsSL https://raw.githubusercontent.com/devcontainers/features/main/src/common-utils/scripts/devcontainers.zsh-theme -o $THEME_DEST

# oh-my-zsh settings
cat << "EOF" >> ~/.zshrc
# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="devcontainers"
plugins=(git)
source $ZSH/oh-my-zsh.sh
EOF
