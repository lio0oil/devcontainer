#!/bin/sh

CURRENT=$(cd $(dirname $0) && pwd)
cd $CURRENT

sh ./.dotconfig/.scripts/homebrew.sh
sh ./.dotconfig/.scripts/zsh_plugin.sh
sh ./.dotconfig/.scripts/zaw.sh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# change uv
# zsh ./.dotconfig/.scripts/pyenv.sh
# zsh ./.dotconfig/.scripts/poetry.sh
zsh ./.dotconfig/.scripts/uv.sh
# zsh ./.dotconfig/.scripts/nodejs.sh
zsh ./.dotconfig/.scripts/volta.sh
zsh ./.dotconfig/.scripts/aws_cli.sh
zsh ./.dotconfig/.scripts/aws_cdk.sh

# code command connot be foundm so i will install it mamually.
# zsh ./.dotconfig/.scripts/vscode_extension.sh

# setting by scripts 
# zsh ./.dotconfig/.scripts/copy_profile.sh