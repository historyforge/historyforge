#!/usr/bin/env bash
set -e

# Wait for PostgreSQL to be ready (it's running in a separate container)
echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h db -U postgres > /dev/null 2>&1; do
  echo "PostgreSQL is not ready yet, waiting..."
  sleep 2
done
echo "PostgreSQL is ready!"

# Now exec the CMD from the Dockerfile or devcontainer
exec "$@"