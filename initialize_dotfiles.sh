### symlink dotfiles
ln -fs $(pwd)/.zshrc $HOME/
ln -fs $(pwd)/.tmux.conf $HOME/

mkdir -p $HOME/.config/nvim
ln -fs $(pwd)/init.lua $HOME/.config/nvim
ln -fs $(pwd)/lua $HOME/.config/nvim

apt update && apt install -y \
  curl \
  python3 \
  ranger \
  ripgrep \
  sshpass \
  tig \
  tmux \
  tree \
  python3-venv \
  xclip \
  zsh

### fzf
dev git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# download neovim
wget https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-arm64.tar.gz
tar -xzf nvim-linux-x86_64.tar.gz -C /opt/nvim
ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim

### Tmux
git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm

### OMZ
KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

### alacritty
