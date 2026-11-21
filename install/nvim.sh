#!/bin/bash
set -euo pipefail

# A nightly build (0.13-dev, for :connect ssh://) pinned as a release of this repo. Once 0.13
# is out, point this at the official release instead.
NVIM_URL=https://github.com/j-o-eriksson/dotfiles/releases/download/nvim-v0.13.0-dev-2152/nvim-linux-x86_64.tar.gz
NVIM_SHA256=87032f548ec913499b8c9189e2b3fdf2699bb1df8a9dd17f809c538e24679b4c
TREE_SITTER_VERSION=0.27.2

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/nvim.tar.gz" "$NVIM_URL"
echo "$NVIM_SHA256  $tmp/nvim.tar.gz" | sha256sum -c --quiet
$SUDO rm -rf /opt/nvim-linux-x86_64
$SUDO tar -xzf "$tmp/nvim.tar.gz" -C /opt
$SUDO ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# The tree-sitter CLI builds nvim-treesitter's parsers. Its prebuilt binary needs glibc 2.39,
# so older systems (Ubuntu 22.04) build it with cargo instead.
glibc="$(ldd --version | head -1 | grep -oE '[0-9]+\.[0-9]+$')"
if [ "$(printf '%s\n' 2.39 "$glibc" | sort -V | head -1)" = 2.39 ]; then
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/download/v$TREE_SITTER_VERSION/tree-sitter-linux-x64.gz" |
    gunzip > "$tmp/tree-sitter"
else
  [ -x "$HOME/.cargo/bin/cargo" ] ||
    curl -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path
  "$HOME/.cargo/bin/cargo" install --locked --root "$tmp/cargo" tree-sitter-cli --version "$TREE_SITTER_VERSION"
  mv "$tmp/cargo/bin/tree-sitter" "$tmp/tree-sitter"
fi
$SUDO install -m 755 "$tmp/tree-sitter" /usr/local/bin/tree-sitter

# Left behind by the old kickstart config's lazy.nvim.
rm -rf "$HOME/.local/share/nvim/lazy" "$HOME/.local/state/nvim/lazy"

# Plugins, parsers and language servers, so the first start is ready to use.
nvim --headless -c "luafile $DOTFILES/install/nvim-bootstrap.lua"
