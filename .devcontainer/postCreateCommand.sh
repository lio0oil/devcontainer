#!/bin/sh

CURRENT=$(cd $(dirname $0) && pwd)
cd $CURRENT

sh ./.dotconfig/.scripts/homebrew.sh
sh ./.dotconfig/.scripts/zsh_plugin.sh
sh ./.dotconfig/.scripts/zaw.sh
sh ./.dotconfig/.scripts/pyenv.sh
sh ./.dotconfig/.scripts/aws.sh
#sh ./.dotconfig/.scripts/config.sh
#sh ./.files/nodejs.sh
#sh ./.files/zsh.sh
#pip3 install -r requirements.txt

source ~/.zshrc