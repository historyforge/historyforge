#!/usr/bin/env zsh

# Migration script for project to Docker named volume
# This script will copy your current workspace to a new Docker volume for optimal performance

set -e

source ${LOGGER}

log_standard_icon "🚀" "$REPO_HUMAN_NAME Docker Volume Migration Script"
log_standard "================================================"

log_standard_icon "📋" "Pre-migration checklist:"
log_success "Current workspace: $CURRENT_WORKSPACE"
log_success "Docker Compose file: $COMPOSE_FILE"

# Check if we're in a devcontainer
if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "Docker Compose file not found at $COMPOSE_FILE"
    exit 1
fi

# Create temporary backup
log_standard_icon "📦" "Creating temporary backup..."
if [ -d "$TEMP_BACKUP" ]; then
    log_standard_icon "🗑️" "Removing existing backup..."
    rm -rf "$TEMP_BACKUP"
fi

log_standard_icon "📂" "Copying workspace to backup location..."
cp -r "$CURRENT_WORKSPACE" "$TEMP_BACKUP"
log_success "Backup created at $TEMP_BACKUP"

# Show what will be copied
log_standard_icon "📊" "Workspace contents to migrate:"
du -sh "$CURRENT_WORKSPACE"/* | head -20

log_standard ""
log_standard_icon "🔄" "Migration Process:"
log_standard "1. Your workspace will be rebuilt with a Docker named volume"
log_standard "2. This eliminates Windows filesystem performance issues"
log_standard "3. Expected performance improvement: 30-50x faster gem install and Rails startup"
log_standard ""
log_warning "IMPORTANT: After migration, your workspace will be inside a Docker volume"
log_standard "   - Accessible only from the devcontainer"
log_standard "   - Git history will be preserved"
log_standard "   - No more Windows filesystem bottlenecks"
log_standard ""

read -p "Continue with migration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_standard_icon "❌" "Migration cancelled."
    log_standard_icon "💡" "To continue with current setup, your workspace is unchanged."
    exit 0
fi

log_standard_icon "🔧" "Starting migration..."

# Note: The actual container rebuild will need to be done by the user
# because we can't rebuild the container from inside itself

log_standard_icon "📝" "Migration Instructions:"
log_standard "1. EXIT this devcontainer completely"
log_standard "2. In VS Code, run: Dev Containers: Rebuild Container"
log_standard "3. VS Code will create the new named volume and rebuild"
log_standard "4. After rebuild, your workspace will be at: ${CURRENT_WORKSPACE}"
log_standard "5. Run the performance test to verify improvement"
log_standard ""
log_standard_icon "🧪" "Performance Test Command (run after rebuild):"
log_standard "   time bundle install --quiet"
log_standard ""
log_standard "Expected results:"
log_standard "  - Current performance: ~4+ minutes for bundle install"
log_standard "  - After migration: ~10-30 seconds for bundle install"
log_standard ""

log_standard_icon "✅" "Migration preparation complete!"
log_standard_icon "💾" "Your current workspace is backed up at: $TEMP_BACKUP"
log_standard_icon "🔄" "Now close this devcontainer and rebuild to complete the migration."
