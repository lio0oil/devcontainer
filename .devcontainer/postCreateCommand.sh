#!/bin/sh

CURRENT=$(cd $(dirname $0) && pwd)
cd $CURRENT

# os update
sudo apt-get update && sudo apt-get upgrade -y

# zsh
sh ./.dotconfig/.scripts/zsh.sh

# homebrew & packages (zsh-completions, zsh-autosuggestions, zsh-syntax-highlighting, fzf, uv, volta, awscli, aws-cdk, docker)
sh ./.dotconfig/.scripts/homebrew.sh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# oh-my-zsh & zsh plugins
sh ./.dotconfig/.scripts/zsh_plugin.sh

# zshrc & theme
sh ./.dotconfig/.scripts/copy_profile.sh

# python
sh ./.dotconfig/.scripts/python.sh

# node.js
sh ./.dotconfig/.scripts/node.sh

# java
bash ./.dotconfig/.scripts/java_sdkman.sh

# go
sh ./.dotconfig/.scripts/go.sh

# rust
sh ./.dotconfig/.scripts/rust.sh

# ai cli (claude code, gemini cli, kiro cli)
sh ./.dotconfig/.scripts/ai_cli.sh

# docker socket
sh ./.dotconfig/.scripts/docker.sh

# vscode extensions (linux only - devcontainer uses postAttachCommand)
if [ -z "$REMOTE_CONTAINERS" ] && [ -z "$CODESPACES" ]; then
    sh ./.dotconfig/.scripts/vscode_extension.sh
fi
