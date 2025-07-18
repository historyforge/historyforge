#!/usr/bin/env zsh
# Load and expand environment variables properly
load_env_with_expansion() {
    local env_file="$1"
    [[ -f "$env_file" ]] || return 1

    # First pass: load simple variables
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | sed 's/^"//;s/"$//')

        export "$key"="$value"
    done < "$env_file"

    # Second pass: expand variables that reference other variables
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs | sed 's/^"//;s/"$//')

        # Expand any variable references in the value
        expanded_value=$(eval echo "$value")
        export "$key"="$expanded_value"
    done < "$env_file"
}

load_env_with_expansion "/workspaces/historyforge/.devcontainer/devcontainer.env"

# Post-create setup for project in Docker volume
# This script runs after the container is created to set up the workspace

set -e

source ${LOGGER}

PROJECT_STAGING="/tmp/project-staging"

log_standard_icon "🔧" "$REPO_HUMAN_NAME Post-Create Setup"
log_standard "===================================="

# Check if workspace directory exists and is empty (first time setup)
if [ ! -d "$WORKSPACE_DIR" ] || [ -z "$(ls -A $WORKSPACE_DIR 2>/dev/null)" ]; then
    log_standard_icon "📂" "Setting up workspace directory..."
    mkdir -p "$WORKSPACE_DIR"

    if [ -d "$PROJECT_STAGING" ]; then
        log_standard_icon "📋" "Copying project files from staging area to workspace volume..."
        cp -r "$PROJECT_STAGING"/* "$WORKSPACE_DIR"/
        cp -r "$PROJECT_STAGING"/.[!.]* "$WORKSPACE_DIR"/ 2>/dev/null || true  # Copy hidden files, ignore errors if none exist
        log_success "Project files copied to workspace volume"
    else
        log_standard_icon "ℹ️" "No staging area found - workspace is empty"
        log_standard_icon "📝" "To populate workspace:"
        log_standard "   1. Clone your repository: git clone <your-repo-url> ."
        log_standard "   2. Or copy files from your host system"
        log_standard "   3. The workspace will persist in the Docker volume"
    fi
else
    log_success "Workspace directory already exists with content"
fi

# Set up git configuration if it doesn't exist
if [ ! -f "$WORKSPACE_DIR/.git/config" ] && [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
    log_standard_icon "🔧" "Setting up git configuration..."
    cd "$WORKSPACE_DIR"
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    log_success "Git configuration complete"
fi

# Clean up staging area to save space
if [ -d "$PROJECT_STAGING" ]; then
    log_standard_icon "🧹" "Cleaning up staging area..."
    rm -rf "$PROJECT_STAGING"
fi

log_success "Post-create setup complete!"
log_standard_icon "📍" "Workspace location: $WORKSPACE_DIR"
log_standard_icon "💾" "Data persists in Docker named volume: ${REPO_NAME}-workspace"
