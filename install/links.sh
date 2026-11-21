#!/bin/bash
# Links the configs into place, so a `git pull` updates them and edits land in the repo.
set -euo pipefail

mkdir -p "$HOME/.config"
ln -sfn "$DOTFILES/.zshrc" "$HOME/.zshrc"
ln -sfn "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
# A real directory here would get the link created inside it instead.
rm -rf "$HOME/.config/nvim"
ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"

if [ ! -e "$HOME/.ssh/config" ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  cp "$DOTFILES/ssh/config.example" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi
