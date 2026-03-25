#!/bin/sh

DIR=$(dirname $0)
. $DIR/config.sh

if [ "$INSTALL_PYTHON" != "true" ]; then
    echo "Skip Python installation."
    exit 0
fi

if [ -n "$INSTALL_PYTHON_VERSION" ]; then
    uv python install $INSTALL_PYTHON_VERSION
else
    uv python install
fi

# python コマンドとして使えるようにシンボリックリンクを作成
UV_PYTHON=$(uv python find 2>/dev/null)
if [ -n "$UV_PYTHON" ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$UV_PYTHON" "$HOME/.local/bin/python"
fi

# ~/.local/bin を PATH に追加
cat << "EOF" >> ~/.zshrc
# python (uv)
export PATH="$HOME/.local/bin:$PATH"
EOF
