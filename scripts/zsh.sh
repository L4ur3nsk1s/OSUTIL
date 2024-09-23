#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh > ~/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh > ~/.oh-my-zsh/plugins/git/git.plugin.zsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/extract/extract.plugin.zsh > ~/.oh-my-zsh/plugins/extract/extract.plugin.zsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh > ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo "source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >>~/.zshrc
echo "source ~/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>~/.zshrc
echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" >>~/.zshrc
echo "alias zshconfig=\"vim ~/.zshrc\"" >>~/.zshrc
echo "alias ohmyzsh=\"vim ~/.oh-my-zsh\"" >>~/.zshrc
source ~/.zshrc
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh > ~/.oh-my-zsh/plugins/git/git.plugin.zsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/extract/extract.plugin.zsh > ~/.oh-my-zsh/plugins/extract/extract.plugin.zsh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh > ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh