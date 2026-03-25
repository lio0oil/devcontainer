#!/bin/sh

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Install Oh My Zsh"
    KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

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
