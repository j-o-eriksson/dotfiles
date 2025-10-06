### symlink dotfiles
ln -fs $(pwd)/.zshrc $HOME/
ln -fs $(pwd)/.tmux.conf $HOME/

mkdir -p $HOME/.config/nvim
ln -fs $(pwd)/init.lua $HOME/.config/nvim
ln -fs $(pwd)/lua $HOME/.config/nvim

apt update && apt install -y \
  g++ \
  bear \
  unzip \
  curl \
  wget \
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

# download and install neovim
wget https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz
tar -xzf nvim-linux-x86_64.tar.gz -C /opt
rm nvim-linux-x86_64.tar.gz
ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

### fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes "y" | ~/.fzf/install

### Tmux
# git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm

### OMZ
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
yes "y" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

zsh
source ~/.zshrc
