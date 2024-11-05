#!/bin/sh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

if test ! $(which brew); then
    echo "Install HomeBrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
    sudo apt-get install build-essential

    (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$(id -u -n)/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    cat << "EOF" >> ~/.zshrc
# HomeBrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
DISABLE_AUTO_UPDATE=true
DISABLE_UPDATE_PROMPT=true
EOF
else
    echo "HomeBrew is already installed."
fi

DIR=`dirname $0`
cd $DIR
brew bundle --file "../.files/homebrew/Brewfile"
