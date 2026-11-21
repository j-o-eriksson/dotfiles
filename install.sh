#!/bin/bash
# Sets up this box's tools from the dotfiles. Every step is safe to re-run, which is also how
# a tool is updated.
#
# Usage: ./install.sh [step...]   steps: packages links zsh tmux nvim (default: all, in that order)
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
SUDO=""
[ "$(id -u)" -eq 0 ] || SUDO="sudo"
export DOTFILES SUDO

# Replaces DIR with a clone of a GitHub repo at a tag or commit: clone_pinned REPO REF DIR
clone_pinned() {
  rm -rf "$3"
  git init -q "$3"
  git -C "$3" fetch -q --depth 1 "https://github.com/$1" "$2"
  git -C "$3" checkout -q FETCH_HEAD
}
export -f clone_pinned

steps=("$@")
[ ${#steps[@]} -gt 0 ] || steps=(packages links zsh tmux nvim)
for step in "${steps[@]}"; do
  echo "==> $step"
  bash "$DOTFILES/install/$step.sh" || { echo "!! step '$step' failed" >&2; exit 1; }
done
