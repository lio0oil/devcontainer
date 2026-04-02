#!/bin/sh

if ! type zsh > /dev/null 2>&1; then
    echo "Install zsh"
    if type apt-get > /dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif type dnf > /dev/null 2>&1; then
        sudo dnf install -y zsh
    elif type yum > /dev/null 2>&1; then
        sudo yum install -y zsh
    else
        echo "No supported package manager found (apt-get / dnf / yum)."
        exit 1
    fi
else
    echo "zsh is already installed."
fi

sudo chsh -s $(which zsh) vscode
