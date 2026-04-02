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

# zsh-completions
cat << "EOF" >> ~/.zshrc
# zsh-completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit
    compinit
fi
EOF

# zsh-autosuggestions
cat << "EOF" >> ~/.zshrc
# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
EOF

# zsh-syntax-highlighting
cat << "EOF" >> ~/.zshrc
# zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

# fzf
cat << "EOF" >> ~/.zshrc
# fzf
eval "$(fzf --zsh)"
EOF
