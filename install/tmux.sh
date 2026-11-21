#!/bin/bash
# Reinstalls TPM and the tmux plugins from scratch, at the versions pinned here and in
# .tmux.conf.
set -euo pipefail

plugins="$HOME/.tmux/plugins"
rm -rf "$plugins"
clone_pinned tmux-plugins/tpm v3.1.0 "$plugins/tpm"
"$plugins/tpm/bin/install_plugins"
