# Dev Container Setup

This project uses a pre-built dev container image hosted on GitHub Container Registry (GHCR) for faster startup times.

## Usage

### Prerequisites
- Docker installed
- Visual Studio Code with Remote - Containers extension
- GitHub account with access to the repository
- Personal Access Token (PAT) with `write:packages` scope for pushing images

## Getting Started
1. Set the namespace and repository in `.devcontainer/devcontainer.json`:
   ```json
    "name": "HistoryForge",
    "service": "historyforge",
    "workspaceFolder": "/workspaces/historyforge",
   ```
2. Set the your custom variables for the project name in `.devcontainer/devcontainer.env`:
   ```env
   REPO_NAME="historyforge"
   REPO_HUMAN_NAME="HistoryForge"
   REPO_DESCRIPTION="HistoryForge is a web-based platform for creating and managing historical maps and visualizations."
   REPO_URL="https://github.com/Jacrys/historyforge"
   ```

### Using Pre-built Image (Default)
The default configuration uses a pre-built image from GHCR. Just open the project in VS Code and reopen in container.

### Using Local Build (Development)
When making changes to the dev container setup:

1. Uncomment the `docker-compose.dev.yml` line in `.devcontainer/devcontainer.json`
2. Rebuild the container

### Building and Pushing New Images

#### Automatic (Recommended)
Images are automatically built and pushed when:
- Changes are pushed to main/master branch
- Changes are made to `.devcontainer/**`, `Gemfile*`, `package.json`, or `yarn.lock`
- Manual workflow dispatch is triggered

#### Manual
```bash
# Set environment variables
export GITHUB_USERNAME="your-username"
export GHCR_TOKEN="your-personal-access-token"

# Build and push
./.devcontainer/build-and-push.sh [tag]
```

## Image Registry

Images are stored at: `ghcr.io/jacrys/historyforge-devcontainer`

Available tags:
- `latest` - Latest build from main branch
- `main-<sha>` - Specific commit builds
- Custom tags from manual builds

## Files

- `docker-compose.yml` - Uses pre-built image
- `docker-compose.dev.yml` - Override for local building
- `build-and-push.sh` - Manual build script
- `.github/workflows/build-devcontainer.yml` - Automated CI/CD
