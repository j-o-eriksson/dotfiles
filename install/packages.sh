#!/bin/bash
set -euo pipefail

$SUDO apt-get update
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  ca-certificates \
  curl \
  git \
  gzip \
  python3 \
  python3-venv \
  ranger \
  ripgrep \
  sshpass \
  tig \
  tmux \
  tree \
  unzip \
  zsh
