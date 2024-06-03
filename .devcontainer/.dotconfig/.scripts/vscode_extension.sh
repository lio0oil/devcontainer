#!/bin/sh

DIR=`dirname $0`
CONFIG="${DIR}/vscode_extention.txt"

for l in `cat ${CONFIG}`;do
    code --install-extension ${l} --force
done