#!/bin/zsh

curl -sSL https://install.python-poetry.org | python3 -


cat << "EOF" >> ~/.zshrc
# poetry
export "PATH=$PATH:$HOME/.local/bin"
EOF

. ~/.zshrc

mkdir ~/.zfunc
poetry completions zsh > ~/.zfunc/_poetry
echo "fpath+=~/.zfunc" >> ~/.zshrc
echo "autoload -Uz compinit && compinit" >> ~/.zshrc

. ~/.zshrc

poetry config virtualenvs.prefer-active-python true