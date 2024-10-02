#!/bin/zsh

cd `dirname $0`
cd ..

cp -r .files/zsh/. ~/.dotconfig

for filepath in ~/.dotconfig/.??*
do
    echo $filepath
    echo ~/$(basename $filepath)
    ln -sfv $filepath ~/$(basename $filepath)
done
