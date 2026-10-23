#!/bin/bash

curl -fsSL https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

source ~/.zshrc

echo 'mise setup complete'

make config
