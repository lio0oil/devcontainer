#!/bin/bash

cd $(cd $(dirname $0);pwd)

pip3 install -r requirements.txt
sh ../.files/aws.sh
sh ../.files/nodejs.sh
sh ../.files/zsh.sh


