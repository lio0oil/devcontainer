#!/bin/sh

DIR=$(dirname $0)
. $DIR/config.sh

if [ "$INSTALL_JAVA" != "true" ]; then
    echo "Skip Java installation."
    exit 0
fi

curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

if [ -n "$INSTALL_JAVA_VERSION" ]; then
    sdk install java $INSTALL_JAVA_VERSION
else
    sdk install java
fi
