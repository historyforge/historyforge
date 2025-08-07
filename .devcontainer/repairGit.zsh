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

# Method 3: Using sed for complex URL parsing
extractUserRepoWithSed() {
    local url="$1"
    echo "$url" | sed -E 's|.*github\.com/([^/]+/[^/]+)(\.git)?.*|\1|'
}

REPO=$(extractUserRepoWithSed "$REPO_URL")

load_env_with_expansion "${WORKSPACE_DIR}/.devcontainer/devcontainer.env"

source "$LOGGER"

log_success "Git repair script initialized using GitHub CLI approach"

# Create backup of current changes
log_standard_icon "💾" "Creating backup of current workspace..."
mkdir -p "$TEMP_BACKUP"

log_standard_icon "📦" "Backing up devcontainer configuration..."
if [[ -d ".devcontainer" ]]; then
    cp -r .devcontainer "$TEMP_BACKUP/"
    log_success "Backed up .devcontainer directory"
fi

if [[ -f ".env" ]]; then
    cp .env "$TEMP_BACKUP/"
    log_success "Backed up .env file"
fi

# Backup any other local files you want to preserve
if [[ -f "docker-compose.override.yml" ]]; then
    cp docker-compose.override.yml "$TEMP_BACKUP/"
    log_success "Backed up docker-compose.override.yml"
fi

# Move to parent directory and remove current workspace
log_standard_icon "🗂️" "Moving to parent directory..."
cd /workspaces

# Remove the current directory
log_warning "Removing current workspace directory..."
rm -rf historyforge

# Ensure GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is not installed. Please install it to proceed."
    exit 1
fi

# Ensure we are authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
    log_warning "You are not authenticated with GitHub CLI. Running 'gh auth login'..."
    gh auth login
fi

# Ensure the repository exists on GitHub
if ! gh repo view "$REPO" &> /dev/null; then
    log_error "Repository '$REPO' does not exist on GitHub. Please create it first."
    exit 1
fi

# Clone fresh from GitHub using GitHub CLI
log_standard_icon "📥" "Cloning fresh repository from GitHub..."
gh repo clone "$REPO"

# Move into the fresh repository
cd "$REPO_NAME"

# Copy local changes back from backup
log_standard_icon "📦" "Restoring local changes from backup..."

if [[ -d "$TEMP_BACKUP/" ]]; then
    cp -r "$TEMP_BACKUP/" .
    log_success "Restored backup files"
fi

# Stage and commit the local changes
log_standard_icon "📝" "Staging local changes..."
git add . 2>/dev/null || true

if git diff --staged --quiet; then
    log_warning "No local changes to commit"
else
    log_standard_icon "💾" "Committing local changes..."
    git commit -m "Add devcontainer configuration and local environment"

    log_standard_icon "📤" "Pushing changes to remote repository..."
    git push origin main

    log_success "Local changes committed and pushed"
fi

# Clean up backup
log_standard_icon "🧹" "Cleaning up backup files..."
rm -rf "$TEMP_BACKUP"
log_success "Backup files cleaned up"

log_success "Git repository repair completed successfully!"
log_standard_icon "✅" "Fresh repository cloned with local changes preserved"
log_standard_icon "🔄" "You can now continue working in the fresh repository."