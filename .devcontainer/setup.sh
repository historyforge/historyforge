#!bin/zsh
LOG_FILE="/workspaces/greenwood-kiosk/.devcontainer/setup.log"
echo -e "\e[33mSetting up the dev container...\e[0m" | tee $LOG_FILE
echo -e "\e[33mConfiguring dotfiles...\e[0m" | tee -a $LOG_FILE
if [[ -d "/root/.config" ]]; then
    echo -e "\e[33m/root/.config already exists: skipping creation\e[0m" | tee -a $LOG_FILE
else
    echo -e "\e[33m/root/.config does not exist: creating...\e[0m" | tee -a $LOG_FILE
    sudo mkdir /root/.config | tee -a $LOG_FILE
fi
cd /root/.config
git config --global init.defaultBranch main | tee -a $LOG_FILE
echo $(pwd) | tee -a $LOG_FILE
current_dir=$(pwd)
if [[ "$current_dir" = "/root/.config" ]]; then
    git init . | tee -a $LOG_FILE
    echo -e "\e[33mCloning the dotfiles repo...\e[0m" | tee -a $LOG_FILE
    git remote add origin https://github.com/Greenwood-Cultural-Center/dotfiles.git | tee -a $LOG_FILE
    git pull origin main | tee -a $LOG_FILE
    echo -e "\e[33mMoving dotfiles to the user directory...\e[0m" | tee -a $LOG_FILE
    mv /root/.config/.zshrc /root/.zshrc | tee -a $LOG_FILE
    mv /root/.config/.p10k.zsh /root/.p10k.zsh | tee -a $LOG_FILE
else
    echo -e "\e[31mNot in /root/.config: skipping dotfiles setup for root: Please manually clone the dotfiles repo, https://github.com/Greenwood-Cultural-Center/dotfiles.git, to /root/.config" | tee -a $LOG_FILE
fi
echo -e "\e[33mChanging to the project directory...\e[0m" | tee -a $LOG_FILE
cd /workspaces/greenwood-kiosk 
echo -e "\e[33mInstalling fzf via Homebrew...\e[0m" | tee -a $LOG_FILE
brew install fzf | tee -a $LOG_FILE
echo -e "\e[33mInstalling powerlevel10k...\e[0m" | tee -a $LOG_FILE
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k | tee -a $LOG_FILE
echo -e "\e[33mInstalling Gems...\e[0m" | tee -a $LOG_FILE
bundle install | tee -a $LOG_FILE
ln -s /usr/local/rvm/rubies/default/bin/ruby /usr/local/rvm/gems/default/bin/ruby
echo -e "\e[33mInstalling NPM packages...\e[0m" | tee -a $LOG_FILE
yarn install | tee -a $LOG_FILE