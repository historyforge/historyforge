#!bin/zsh
LOG_FILE="${WORKSPACE_DIR}/.devcontainer/setup.log"
echo -e " 📦\e[33mSetting up the dev container...\e[0m" | tee $LOG_FILE
echo -e " 📂\e[33mConfiguring dotfiles...\e[0m" | tee -a $LOG_FILE
echo -e "📂\e[33m Setting up dotfiles...\e[0m" | tee -a $LOG_FILE
cp -r ${WORKSPACE_DIR}/.devcontainer/dotfiles/. /root  | tee -a $LOG_FILE

echo -e "📂\e[33mChanging to the project directory...\e[0m" | tee -a $LOG_FILE
cd ${WORKSPACE_DIR}
echo -e "🔍\e[33mInstalling fzf via Homebrew...\e[0m" | tee -a $LOG_FILE
brew install fzf | tee -a $LOG_FILE
echo -e "⚡\e[33mInstalling powerlevel10k...\e[0m" | tee -a $LOG_FILE
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k | tee -a $LOG_FILE
echo -e "💎\e[33mInstalling Gems...\e[0m" | tee -a $LOG_FILE
bundle install | tee -a $LOG_FILE
echo -e "📦\e[33mInstalling NPM packages...\e[0m" | tee -a $LOG_FILE
yarn install | tee -a $LOG_FILE