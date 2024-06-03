#!/bin/sh

cd `dirname $0`
cd ..

cp -r .files/zsh ~

for filepath in ~/.dotconfig/.??*
do
    echo $filepath
    echo ~/$(basename $filepath)
    ln -sfnv $filepath ~/$(basename $filepath)
done
