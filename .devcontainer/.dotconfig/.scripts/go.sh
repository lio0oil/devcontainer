#!/bin/sh

DIR=$(dirname $0)
. $DIR/config.sh

if [ "$INSTALL_GO" != "true" ]; then
    echo "Skip Go installation."
    exit 0
fi

cat << "EOF" >> ~/.zshrc
# goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
EOF

export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"

if [ -n "$INSTALL_GO_VERSION" ]; then
    goenv install $INSTALL_GO_VERSION
    goenv global $INSTALL_GO_VERSION
else
    LATEST=$(goenv install --list 2>/dev/null | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+\s*$' | tail -1 | tr -d ' \t')
    goenv install $LATEST
    goenv global $LATEST
fi
