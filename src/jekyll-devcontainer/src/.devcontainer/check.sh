#! /bin/zsh

cd ./.devcontainer
cat packages.txt
apt-get -s install < packages.txt
