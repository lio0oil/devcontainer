#!/bin/sh

# nvmをダウンロードしてインストールする：
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

export NVM_DIR="/usr/local/share/nvm"

# シェルを再起動する代わりに実行する
\. "$NVM_DIR/nvm.sh"

# Node.jsをダウンロードしてインストールする：
nvm install 22

# Node.jsのバージョンを確認する：
node -v # "v22.14.0"が表示される。
nvm current # "v22.14.0"が表示される。

# npmのバージョンを確認する：
npm -v # "10.9.2"が表示される。

cat << "EOF" >> ~/.zshrc
# Node.js
export NVM_DIR="/usr/local/share/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
