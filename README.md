# HistoryForge

[![Maintainability](https://api.codeclimate.com/v1/badges/ba4431ae9e5100c088e4/maintainability)](https://codeclimate.com/github/jacrys/historyforge/maintainability) [![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/jacrys/historyforge)

This is HistoryForge. It is a basic Rails application.

## Development Setup

### Using Dev Containers (Recommended)

This project includes a fully configured development container that eliminates environment setup issues and provides optimal performance.

**Performance Note**: The devcontainer uses Docker named volumes to avoid Windows filesystem performance issues. This provides 30-50x faster gem installation and Rails startup compared to Windows-mounted volumes.

**First-time Setup**:
1. Open the project in VS Code
2. Click "Reopen in Container" when prompted
3. Wait for the container to build and start
4. Run `.devcontainer/copy-to-volume.sh` if migrating existing workspace

**Performance Test**:
```bash
time bundle install --quiet
# Expected: ~10-30 seconds (vs 4+ minutes on Windows filesystem)
```

### Migration from Windows Filesystem

If you're upgrading from a Windows-mounted workspace:
1. Run `.devcontainer/migrate-to-volume.sh` to prepare migration
2. Close the devcontainer
3. Use "Dev Containers: Rebuild Container" command
4. Run `.devcontainer/copy-to-volume.sh` to restore your workspace

## Setup Production Environment

See the wiki page.
