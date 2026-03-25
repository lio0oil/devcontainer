#!/bin/sh

DIR=$(dirname $0)
. $DIR/config.sh

if [ "$INSTALL_RUST" != "true" ]; then
    echo "Skip Rust installation."
    exit 0
fi

cat << "EOF" >> ~/.zshrc
# cargo (Rust)
export PATH="$HOME/.cargo/bin:$PATH"
EOF

if [ -n "$INSTALL_RUST_VERSION" ]; then
    rustup-init -y --default-toolchain $INSTALL_RUST_VERSION
else
    rustup-init -y
fi
