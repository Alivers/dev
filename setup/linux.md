# New Linux machine setup

Run top to bottom on a fresh Debian/Ubuntu box. Aliases live in [`../dotfiles/`](../dotfiles/).

## Github access

```
ssh-keygen -t ed25519 -C "aliver.len@outlook.com"
cat ~/.ssh/id_ed25519.pub

git config --global user.email "aliver.len@outlook.com"
git config --global user.name "Alivers"
```

## Shell

```
sudo apt install zsh git fonts-font-awesome
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
chsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# .zshrc
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

p10k configure

# change line with additional `%`
unsetopt prompt_cr prompt_sp
```

## Language

```
# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
nvm install --lts

sudo apt-get install python3-pip
```

## Neovim

```
# use nvim-linux-arm64.appimage on ARM
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage
./nvim-linux-x86_64.appimage --appimage-extract
./squashfs-root/AppRun --version

# Optional: exposing nvim globally.
sudo mv squashfs-root neovim
sudo mv neovim /
sudo ln -s /neovim/AppRun /usr/bin/nvim
```

## Tmux

```
sudo apt-get install tmux

cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
```

## Aliases

```
# shell + tmux aliases
curl -fsSL https://raw.githubusercontent.com/Alivers/dev/main/dotfiles/aliases.sh -o ~/.aliases
cat >> ~/.zshrc << 'EOF'
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"
EOF

# git aliases
curl -fsSL https://raw.githubusercontent.com/Alivers/dev/main/dotfiles/git-aliases.gitconfig -o ~/.gitconfig-aliases
git config --global include.path ~/.gitconfig-aliases
```

## Troubleshooting

```
# manpath: can't set the locale; make sure $LC_* and $LANG are correct
sudo locale-gen "en_US.UTF-8"
sudo dpkg-reconfigure locales
echo 'LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/default/locale
```
