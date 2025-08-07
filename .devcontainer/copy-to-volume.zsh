#!/usr/bin/env zsh

# Copy current workspace to Docker volume
# Run this AFTER the container has been rebuilt with the new volume configuration

set -e

source ${LOGGER}

log_standard_icon "📋" "$REPO_HUMAN_NAME Workspace Copy Utility"
log_standard "========================================="

SOURCE_DIR="$WORKSPACE_DIR"
TEMP_BACKUP="/tmp/${REPO_NAME}-migration-backup"

# Check if we have a backup to restore from
if [ -d "$TEMP_BACKUP" ]; then
    log_standard_icon "📦" "Found backup at: $TEMP_BACKUP"
    log_standard_icon "📁" "Current workspace: $SOURCE_DIR"

    # Show current workspace status
    log_standard_icon "📊" "Current workspace contents:"
    if [ -d "$SOURCE_DIR" ] && [ "$(ls -A $SOURCE_DIR 2>/dev/null)" ]; then
        ls -la "$SOURCE_DIR" | head -10
        log_standard "..."
    else
        log_standard "  (empty or doesn't exist)"
    fi

    log_standard ""
    read -p "Copy backup to current workspace? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_standard_icon "🔄" "Copying backup to workspace..."

        # Ensure target directory exists
        mkdir -p "$SOURCE_DIR"

        # Copy all contents from backup, preserving git
        rsync -av --exclude='.git' "$TEMP_BACKUP/" "$SOURCE_DIR/"

        # Handle .git directory specially if it exists
        if [ -d "$TEMP_BACKUP/.git" ]; then
            log_standard_icon "📋" "Preserving git repository..."
            cp -r "$TEMP_BACKUP/.git" "$SOURCE_DIR/"
        fi

        log_success "Workspace copied successfully!"
        log_standard_icon "🧹" "Cleaning up backup..."
        rm -rf "$TEMP_BACKUP"

        # Verify git status
        cd "$SOURCE_DIR"
        if [ -d ".git" ]; then
            log_standard_icon "🔍" "Git repository status:"
            git status --porcelain | head -5
            log_standard_icon "📍" "Current branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
        else
            log_standard_icon "⚠️" "No git repository found - you may need to reinitialize"
        fi

        # Show final workspace status
        log_standard_icon "📊" "Final workspace status:"
        ls -la "$SOURCE_DIR" | head -10
        log_standard "..."

        log_standard ""
        log_standard_icon "🧪" "Performance Test:"
        log_standard "Run this command to test the performance improvement:"
        log_standard "  time bundle install --quiet"
        log_standard ""
        log_standard "Expected improvement: 30-50x faster than before!"

    else
        log_error "Copy cancelled."
        log_standard_icon "💾" "Backup remains at: $TEMP_BACKUP"
    fi

else
    log_error "No backup found at: $TEMP_BACKUP"
    log_standard_icon "💡" "If you need to manually copy files:"
    log_standard "   1. Use 'git clone' to get your repository"
    log_standard "   2. Or manually copy files from your host system"
    log_standard "   3. The workspace will persist in the Docker volume"
fi

log_standard ""
log_standard_icon "📍" "Workspace location: $SOURCE_DIR"
log_standard_icon "💾" "This workspace is now stored in Docker volume: ${REPO_NAME}-workspace"
log_standard_icon "🚀" "Enjoy the improved performance!"