#!/usr/bin/env bash
set -e

# Start Postgres if not running
if ! pg_isready -U postgres > /dev/null 2>&1; then
  echo "Starting PostgreSQL..."
  su - postgres -c "/usr/lib/postgresql/16/bin/pg_ctl -D /var/lib/postgresql/data -l /var/log/postgresql/startup.log start"
fi

# Now exec the CMD from the Dockerfile or devcontainer
exec "$@"