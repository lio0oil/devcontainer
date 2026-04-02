#!/bin/sh

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Install Oh My Zsh"
    KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi
