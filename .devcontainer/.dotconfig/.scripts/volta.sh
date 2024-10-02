#!/bin/zsh

# curl https://get.volta.sh | bash

# manually configure
curl https://get.volta.sh | bash -s -- --skip-setup
cat << "EOF" >> ~/.zshrc
# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
EOF

. ~/.zshrc

volta install node
volta install npm
