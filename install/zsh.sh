#!/bin/bash
# Reinstalls oh-my-zsh, its plugins and fzf from scratch at pinned versions.
set -euo pipefail

rm -rf "$HOME/.oh-my-zsh" "$HOME/.fzf" "$HOME/.fzf.zsh" "$HOME"/.zcompdump*

# Updates are disabled in .zshrc, so oh-my-zsh stays at this commit.
clone_pinned ohmyzsh/ohmyzsh c0140703a53eb0d22be44f7bac318d0baacc927c "$HOME/.oh-my-zsh"
plugins="$HOME/.oh-my-zsh/custom/plugins"
clone_pinned zsh-users/zsh-syntax-highlighting 0.8.0 "$plugins/zsh-syntax-highlighting"
clone_pinned zsh-users/zsh-autosuggestions v0.7.1 "$plugins/zsh-autosuggestions"

clone_pinned junegunn/fzf v0.75.0 "$HOME/.fzf"
# Fetches the matching fzf binary and writes ~/.fzf.zsh, which .zshrc sources, without
# editing .zshrc itself.
"$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish

zsh_path="$(command -v zsh)"
user="$(id -un)"
[ "$(getent passwd "$user" | cut -d: -f7)" = "$zsh_path" ] || $SUDO chsh -s "$zsh_path" "$user"
