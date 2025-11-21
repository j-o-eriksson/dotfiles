#!/bin/bash

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

### symlink dotfiles
cp $(pwd)/.zshrc $HOME/
cp $(pwd)/.tmux.conf $HOME/

mkdir -p $HOME/.config/nvim
cp $(pwd)/init.lua $HOME/.config/nvim
cp -r $(pwd)/lua $HOME/.config/nvim

$SUDO apt update && $SUDO apt install -y \
  g++ \
  unzip \
  curl \
  wget \
  python3 \
  python3-venv \
  ranger \
  ripgrep \
  sshpass \
  tig \
  tmux \
  tree \
  xclip \
  zsh

# download and install neovim
wget https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz
tar -xzf nvim-linux-x86_64.tar.gz -C /opt
rm nvim-linux-x86_64.tar.gz
ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

### fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes "y" | ~/.fzf/install

### Tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# start zsh
zsh
source ~/.zshrc

### OMZ
yes "y" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
