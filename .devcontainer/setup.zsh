#!/usr/bin/env zsh

source ${LOGGER}

log_standard_icon "📦" "Setting up the dev container..."
log_standard_icon "📂" "Configuring dotfiles..."
log_standard_icon "📂" "Setting up dotfiles..."
cp -r ${WORKSPACE_DIR}/.devcontainer/dotfiles/. /root

log_standard_icon "📂" "Changing to the project directory..."
cd ${WORKSPACE_DIR}
log_standard_icon "🔍" "Installing fzf via Homebrew..."
brew install fzf
log_standard_icon "⚡" "Installing powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k
log_standard_icon "💎" "Installing Gems..."
bundle install
log_standard_icon "📦" "Installing NPM packages..."
yarn installs