#!/usr/bin/env bash

# Build and push dev container image to GHCR
# Usage: ./build-and-push-devcontainer.sh [tag]

set -e

REGISTRY="ghcr.io"
IMAGE_REPO_NAME="jacrys/historyforge-devcontainer"
TAG="${1:-latest}"
IMAGE_NAME="${REGISTRY}/${IMAGE_REPO_NAME}:${TAG}"

echo "🏗️  Building dev container image..."
docker build -f .devcontainer/Dockerfile -t "${IMAGE_NAME}" .

echo "📋 Image built: ${IMAGE_NAME}"
echo "💾 Size: $(docker images --format "table {{.Size}}" "${IMAGE_NAME}" | tail -n1)"

echo "🔐 Logging in to GitHub Container Registry..."
echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GITHUB_USERNAME}" --password-stdin

echo "📤 Pushing image to registry..."
docker push "${IMAGE_NAME}"

echo "✅ Successfully pushed: ${IMAGE_NAME}"
echo ""
echo "To use this image, update your docker-compose.yml:"
echo "  image: ${IMAGE_NAME}"
