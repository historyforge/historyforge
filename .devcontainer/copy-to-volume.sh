#!/bin/bash

# Copy current workspace to Docker volume
# Run this AFTER the container has been rebuilt with the new volume configuration

set -e

echo "📋 HistoryForge Workspace Copy Utility"
echo "========================================="

SOURCE_DIR="/workspaces/historyforge"
TEMP_BACKUP="/tmp/historyforge-migration-backup"

# Check if we have a backup to restore from
if [ -d "$TEMP_BACKUP" ]; then
    echo "📦 Found backup at: $TEMP_BACKUP"
    echo "📁 Current workspace: $SOURCE_DIR"

    # Show current workspace status
    echo "📊 Current workspace contents:"
    if [ -d "$SOURCE_DIR" ] && [ "$(ls -A $SOURCE_DIR 2>/dev/null)" ]; then
        ls -la "$SOURCE_DIR" | head -10
        echo "..."
    else
        echo "  (empty or doesn't exist)"
    fi

    echo ""
    read -p "Copy backup to current workspace? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Copying backup to workspace..."

        # Ensure target directory exists
        mkdir -p "$SOURCE_DIR"

        # Copy all contents from backup
        cp -r "$TEMP_BACKUP/"* "$SOURCE_DIR/"
        cp -r "$TEMP_BACKUP/".* "$SOURCE_DIR/" 2>/dev/null || true

        echo "✅ Workspace copied successfully!"
        echo "🧹 Cleaning up backup..."
        rm -rf "$TEMP_BACKUP"

        # Show final workspace status
        echo "📊 Final workspace status:"
        ls -la "$SOURCE_DIR" | head -10
        echo "..."

        echo ""
        echo "🧪 Performance Test:"
        echo "Run this command to test the performance improvement:"
        echo "  time bundle install --quiet"
        echo ""
        echo "Expected improvement: 30-50x faster than before!"

    else
        echo "❌ Copy cancelled."
        echo "💾 Backup remains at: $TEMP_BACKUP"
    fi

else
    echo "❌ No backup found at: $TEMP_BACKUP"
    echo "💡 If you need to manually copy files:"
    echo "   1. Use 'git clone' to get your repository"
    echo "   2. Or manually copy files from your host system"
    echo "   3. The workspace will persist in the Docker volume"
fi

echo ""
echo "📍 Workspace location: $SOURCE_DIR"
echo "💾 This workspace is now stored in Docker volume: historyforge-workspace"
echo "🚀 Enjoy the improved performance!"
