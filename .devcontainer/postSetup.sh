#!/usr/bin/env zsh
LOG_FILE="${WORKSPACE_DIR}/.devcontainer/postSetup.log"
if [[ -e ".env" ]]; then
    echo -e "\e[33m.env file found: skipping creation\e[0m" | tee $LOG_FILE
else
    echo -e "\e[33mSetting up the environment...\e[0m" | tee -a $LOG_FILE
    cp .exampleenv .env | tee -a $LOG_FILE
fi
echo -e "🔐\e[33mCreating the secret key env vars...\e[0m" | tee -a $LOG_FILE
devise_secret=$(rails secret) | tee -a $LOG_FILE
secret_key_base=$(rails secret) | tee -a $LOG_FILE

if [[ ! -d "${WORKSPACE_DIR}/log" ]]; then
    echo -e "📂\e[33mCreating log directory...\e[0m" | tee -a $LOG_FILE
    mkdir -p "${WORKSPACE_DIR}/log"
fi

export DEVISE_SECRET_KEY=$devise_secret | tee -a $LOG_FILE
export SECRET_KEY_BASE=$secret_key_base | tee -a $LOG_FILE

echo -e "🛢\e[33mChecking if database exists...\e[0m" | tee -a $LOG_FILE

DB_EXISTS=$(rails db:exists 2>&1 | grep -v "^\[dotenv\]" || echo "false")

if echo "$DB_EXISTS" | grep -q "false"; then
    SCHEMA_EXISTS=$(rails db:schema_exists 2>&1 | grep -v "^\[dotenv\]" || echo "false")
    DB_EMPTY=$(rails db:is_empty 2>&1 | grep -v "^\[dotenv\]" || echo "false")

    echo -e "🛢\e[33mDatabase does not exist, creating and setting up...\e[0m" | tee -a $LOG_FILE

    if [[ -e "config/database.yml" ]]; then
        echo -e "🛢\e[33mdatabase.yml file found: skipping creation\e[0m" | tee -a $LOG_FILE
    else
        echo -e "🛢\e[33mCreating database.yml file...\e[0m" | tee -a $LOG_FILE
        cp config/database.example.yml config/database.yml | tee -a $LOG_FILE
    fi

    echo -e "🛢\e[33mCreating the database...\e[0m" | tee -a $LOG_FILE
    rails db:create | tee -a $LOG_FILE
    if echo "$SCHEMA_EXISTS" | grep -q "false"; then
        echo -e "🛢\e[33mLoading schema...\e[0m" | tee -a $LOG_FILE
        rails db:schema:load | tee -a $LOG_FILE
    else
        echo -e "🛢\e[33mSchema already exists: skipping loading\e[0m" | tee -a $LOG_FILE
    fi

    MIGRATIONS_PENDING=$(rails db:has_pending_migrations 2>&1 | grep -v "^\[dotenv\]" | grep -v "ActiveRecord::" | grep -v "↳"  || echo "false")
    if echo "$DB_EMPTY" | grep -q "true"; then
        echo -e "🛢\e[33mSeeding the DB...\e[0m" | tee -a $LOG_FILE
        rails db:seed | tee -a $LOG_FILE
        if echo "$MIGRATIONS_PENDING" | grep -q "true"; then
            echo -e "🛢\e[33mDatabase has pending migrations: running migrations...\e[0m" | tee -a $LOG_FILE
            rails db:migrate | tee -a $LOG_FILE
        else
            echo -e "🛢\e[33mNo pending migrations: skipping migration\e[0m" | tee -a $LOG_FILE
        fi
    else
        echo -e "🛢\e[33mDatabase is not empty: skipping seeding\e[0m" | tee -a $LOG_FILE
    fi
else
    echo -e "🛢\e[33mDatabase already exists: skipping creation and seeding\e[0m" | tee -a $LOG_FILE
fi

export DEVCONTAINER_SETUP=0