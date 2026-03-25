#!/bin/sh

DIR=$(dirname $0)
. $DIR/config.sh

if [ "$INSTALL_NODE" != "true" ]; then
    echo "Skip Node.js installation."
    exit 0
fi

cat << "EOF" >> ~/.zshrc
# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
EOF

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

if [ -n "$INSTALL_NODE_VERSION" ]; then
    volta install node@$INSTALL_NODE_VERSION
else
    volta install node@latest
fi

volta install npm
