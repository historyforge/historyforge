#!/usr/bin/env zsh

source ${LOGGER}

if [[ -e ".env" ]]; then
    log_standard ".env file found: skipping creation"
else
    log_standard "Setting up the environment..."
    cp .exampleenv .env
fi
log_standard "🔐 Creating the secret key env vars..."
devise_secret=$(rails secret)
secret_key_base=$(rails secret)

if [[ ! -d "${WORKSPACE_DIR}/log" ]]; then
    log_standard "📂 Creating log directory..."
    mkdir -p "${WORKSPACE_DIR}/log"
fi

export DEVISE_SECRET_KEY=$devise_secret
export SECRET_KEY_BASE=$secret_key_base

log_standard "🛢 Checking if database exists..."

DB_EXISTS=$(rails db:exists 2>&1 | grep -v "^\[dotenv\]" || echo "false")

if echo "$DB_EXISTS" | grep -q "false"; then
    SCHEMA_EXISTS=$(rails db:schema_exists 2>&1 | grep -v "^\[dotenv\]" || echo "false")
    DB_EMPTY=$(rails db:is_empty 2>&1 | grep -v "^\[dotenv\]" || echo "false")

    log_standard_icon "🛢" "Database does not exist, creating and setting up..."

    if [[ -e "config/database.yml" ]]; then
        log_standard_icon "🛢" "database.yml file found: skipping creation"
    else
        log_standard_icon "🛢" "Creating database.yml file..."
        cp config/database.example.yml config/database.yml
    fi

    log_standard_icon "🛢" "Creating the database..."
    rails db:create
    if echo "$SCHEMA_EXISTS" | grep -q "false"; then
        log_standard_icon "🛢" "Loading schema..."
        rails db:schema:load
    else
        log_standard_icon "🛢" "Schema already exists: skipping loading"
    fi

    MIGRATIONS_PENDING=$(rails db:has_pending_migrations 2>&1 | grep -v "^\[dotenv\]" | grep -v "ActiveRecord::" | grep -v "↳"  || echo "false")
    if echo "$DB_EMPTY" | grep -q "true"; then
        log_standard_icon "🛢" "Seeding the DB..."
        rails db:seed
        if echo "$MIGRATIONS_PENDING" | grep -q "true"; then
            log_standard_icon "🛢" "Database has pending migrations: running migrations..."
            rails db:migrate
        else
            log_standard_icon "🛢" "No pending migrations: skipping migration"
        fi
    else
        log_standard_icon "🛢" "Database is not empty: skipping seeding"
    fi
else
    log_standard_icon "🛢" "Database already exists: skipping creation and seeding"
fi

log_standard_icon "🛠" "Running post setup tasks..."

# SSH key permissions (safer version)
if [[ -d "/root/.ssh" ]]; then
    log_standard_icon "🔐" "Setting SSH key permissions..."
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/id_* 2>/dev/null || true
    chmod 644 /root/.ssh/*.pub 2>/dev/null || true
else
    log_standard_icon "🔐" "No SSH directory found - skipping SSH setup"
fi

log_standard_icon "🔧" "Checking git status..."
if [[ -d ".git" ]]; then
    if git status &>/dev/null; then
        log_standard_icon "✅" "Git repository is healthy"
    else
        log_warning "Git repository has issues - manual intervention required"
    fi
else
    log_warning "No git repository found - manual setup required"
fi

export DEVCONTAINER_SETUP=0


log_standard_icon "🎉" "Post-setup completed!"