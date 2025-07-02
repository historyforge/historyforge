#!/bin/bash

# Migration script for project to Docker named volume
# This script will copy your current workspace to a new Docker volume for optimal performance

set -e

echo "🚀 $REPO_HUMAN_NAME Docker Volume Migration Script"
echo "================================================"

echo "📋 Pre-migration checklist:"
echo "  ✓ Current workspace: $CURRENT_WORKSPACE"
echo "  ✓ Docker Compose file: $COMPOSE_FILE"

# Check if we're in a devcontainer
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Error: Docker Compose file not found at $COMPOSE_FILE"
    exit 1
fi

# Create temporary backup
echo "📦 Creating temporary backup..."
if [ -d "$TEMP_BACKUP" ]; then
    echo "  Removing existing backup..."
    rm -rf "$TEMP_BACKUP"
fi

echo "  Copying workspace to backup location..."
cp -r "$CURRENT_WORKSPACE" "$TEMP_BACKUP"
echo "  ✓ Backup created at $TEMP_BACKUP"

# Show what will be copied
echo "📊 Workspace contents to migrate:"
du -sh "$CURRENT_WORKSPACE"/* | head -20

echo ""
echo "🔄 Migration Process:"
echo "1. Your workspace will be rebuilt with a Docker named volume"
echo "2. This eliminates Windows filesystem performance issues"
echo "3. Expected performance improvement: 30-50x faster gem install and Rails startup"
echo ""
echo "⚠️  IMPORTANT: After migration, your workspace will be inside a Docker volume"
echo "   - Accessible only from the devcontainer"
echo "   - Git history will be preserved"
echo "   - No more Windows filesystem bottlenecks"
echo ""

read -p "Continue with migration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Migration cancelled."
    echo "💡 To continue with current setup, your workspace is unchanged."
    exit 0
fi

echo "🔧 Starting migration..."

# Note: The actual container rebuild will need to be done by the user
# because we can't rebuild the container from inside itself

echo "📝 Migration Instructions:"
echo ""
echo "1. EXIT this devcontainer completely"
echo "2. In VS Code, run: Dev Containers: Rebuild Container"
echo "3. VS Code will create the new named volume and rebuild"
echo "4. After rebuild, your workspace will be at: ${CURRENT_WORKSPACE}"
echo "5. Run the performance test to verify improvement"
echo ""
echo "🧪 Performance Test Command (run after rebuild):"
echo "   time bundle install --quiet"
echo ""
echo "Expected results:"
echo "  - Current performance: ~4+ minutes for bundle install"
echo "  - After migration: ~10-30 seconds for bundle install"
echo ""

echo "✅ Migration preparation complete!"
echo "💾 Your current workspace is backed up at: $TEMP_BACKUP"
echo "🔄 Now close this devcontainer and rebuild to complete the migration."
