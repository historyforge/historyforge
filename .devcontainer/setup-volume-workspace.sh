#!/bin/bash

# Post-create setup for project in Docker volume
# This script runs after the container is created to set up the workspace

set -e

PROJECT_STAGING="/tmp/project-staging"

echo "🔧 $REPO_HUMAN_NAME Post-Create Setup"
echo "===================================="

# Check if workspace directory exists and is empty (first time setup)
if [ ! -d "$WORKSPACE_DIR" ] || [ -z "$(ls -A $WORKSPACE_DIR 2>/dev/null)" ]; then
    echo "📂 Setting up workspace directory..."
    mkdir -p "$WORKSPACE_DIR"

    if [ -d "$PROJECT_STAGING" ]; then
        echo "📋 Copying project files from staging area to workspace volume..."
        cp -r "$PROJECT_STAGING"/* "$WORKSPACE_DIR"/
        cp -r "$PROJECT_STAGING"/.[!.]* "$WORKSPACE_DIR"/ 2>/dev/null || true  # Copy hidden files, ignore errors if none exist
        echo "✅ Project files copied to workspace volume"
    else
        echo "ℹ️  No staging area found - workspace is empty"
        echo "📝 To populate workspace:"
        echo "   1. Clone your repository: git clone <your-repo-url> ."
        echo "   2. Or copy files from your host system"
        echo "   3. The workspace will persist in the Docker volume"
    fi
else
    echo "✅ Workspace directory already exists with content"
fi

# Set up git configuration if it doesn't exist
if [ ! -f "$WORKSPACE_DIR/.git/config" ] && [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
    echo "🔧 Setting up git configuration..."
    cd "$WORKSPACE_DIR"
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    echo "✅ Git configuration complete"
fi

# Clean up staging area to save space
if [ -d "$PROJECT_STAGING" ]; then
    echo "🧹 Cleaning up staging area..."
    rm -rf "$PROJECT_STAGING"
fi

echo "✅ Post-create setup complete!"
echo "📍 Workspace location: $WORKSPACE_DIR"
echo "💾 Data persists in Docker named volume: ${REPO_NAME}-workspace"
