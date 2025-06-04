#!/usr/bin/zsh
LOG_FILE="/workspaces/greenwood-kiosk/.devcontainer/postSetup.log"
if [[ -e ".env" ]]; then
    echo -e "\e[33m.env file found: skipping creation\e[0m" | tee $LOG_FILE
else
    echo -e "\e[33mSetting up the environment...\e[0m" | tee -a $LOG_FILE
    cp .exampleenv .env | tee -a $LOG_FILE
fi
echo -e "\e[33mCreating the secret key env vars...\e[0m" | tee -a $LOG_FILE
devise_secret=$(rails secret) | tee -a $LOG_FILE
secret_key_base=$(rails secret) | tee -a $LOG_FILE

export DEVISE_SECRET_KEY=$devise_secret | tee -a $LOG_FILE
export SECRET_KEY_BASE=$secret_key_base | tee -a $LOG_FILE

echo -e "\e[33mSetting up the database...\e[0m" | tee -a $LOG_FILE
if [[ -e "config/database.yml" ]]; then
    echo -e "\e[33mdatabase.yml file found: skipping creation\e[0m" | tee -a $LOG_FILE
else
    echo -e "\e[33mCreating database.yml file...\e[0m" | tee -a $LOG_FILE
    cp config/database.example.yml config/database.yml | tee -a $LOG_FILE
fi
echo -e "\e[33mCreating the database...\e[0m" | tee -a $LOG_FILE
rails db:create | tee -a $LOG_FILE
echo -e "\e[33mLoading schema...\e[0m" | tee -a $LOG_FILE
rails db:schema:load | tee -a $LOG_FILE
echo -e "\e[33mSeeding the DB...\e[0m" | tee -a $LOG_FILE
rails db:seed | tee -a $LOG_FILE