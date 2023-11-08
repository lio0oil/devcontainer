#!/bin/bash

cd ~
mkdir ~/zsh_plugins
cd zsh_plugins
git clone https://github.com/zsh-users/zaw.git
echo "source ${PWD}/zaw/zaw.zsh" >> ~/.zshrc
echo "bindkey '^R' zaw-history" >> ~/.zshrc
