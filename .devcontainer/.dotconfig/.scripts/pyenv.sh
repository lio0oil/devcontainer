#!/bin/zsh

curl https://pyenv.run | bash

cat << "EOF" >> ~/.zshrc
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF

. ~/.zshrc

cd `dirname $0`
. ./config.sh

pyenv install $INSTALL_PYTHON_VERSION -f
pyenv global $INSTALL_PYTHON_VERSION
