#!bin/zsh
LOG_FILE="/workspaces/historyforge/.devcontainer/setup.log"
echo -e "\e[33mSetting up the dev container...\e[0m" | tee $LOG_FILE
echo -e "\e[33mConfiguring dotfiles...\e[0m" | tee -a $LOG_FILE
if [[ -d "/root/.config" ]]; then
    echo -e "\e[33m/root/.config already exists: skipping creation\e[0m" | tee -a $LOG_FILE
else
    echo -e "\e[33m/root/.config does not exist: creating...\e[0m" | tee -a $LOG_FILE
    sudo mkdir /root/.config | tee -a $LOG_FILE
fi
cd /root/.config
echo $(pwd) | tee -a $LOG_FILE
current_dir=$(pwd)
if [[ "$current_dir" = "/root/.config" ]]; then
    echo -e "\e[33mIn /root/.config: setting up dotfiles...\e[0m" | tee -a $LOG_FILE
    cp -r /workspaces/historyforge/.devcontainer/dotfiles/* .  | tee -a $LOG_FILE
else
    echo -e "\e[31mNot in /root/.config: skipping dotfiles setup for root: Please manually clone the dotfiles to /root/.config" | tee -a $LOG_FILE
fi
echo -e "\e[33mChanging to the project directory...\e[0m" | tee -a $LOG_FILE
cd /workspaces/historyforge
echo -e "\e[33mInstalling fzf via Homebrew...\e[0m" | tee -a $LOG_FILE
brew install fzf | tee -a $LOG_FILE
echo -e "\e[33mInstalling powerlevel10k...\e[0m" | tee -a $LOG_FILE
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k | tee -a $LOG_FILE
echo -e "\e[33mInstalling Gems...\e[0m" | tee -a $LOG_FILE
bundle install | tee -a $LOG_FILE
echo -e "\e[33mInstalling NPM packages...\e[0m" | tee -a $LOG_FILE
yarn install | tee -a $LOG_FILE