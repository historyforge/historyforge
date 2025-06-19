#!/usr/bin/env bash
# This script ensures ruby-lsp runs in the correct RVM and bundler context

# # Ensure RVM is available in this shell
# source /usr/local/rvm/scripts/rvm

# # Use correct Ruby version
# rvm use 3.3.6 --default >/dev/null 2>&1

# # Run the Ruby LSP from within bundler context
# exec bundle exec ruby -I"$(bundle show ruby-lsp)/lib" "$(bundle show ruby-lsp)/exe/ruby-lsp"

ruby -rjson -e 'puts JSON.dump(ENV.to_h)' > /tmp/env-vscode.json

set -euo pipefail

# This must point to the actual location of your Gemfile
export BUNDLE_GEMFILE="/workspaces/greenwood-kiosk/Gemfile"

# Optionally: Ensure bundler is used for all Ruby commands
export BUNDLE_WITHOUT="development:test"

# Now exec the real LSP server (inside Bundler context)
exec bundle exec ruby-lsp "$@"

puts "[ruby-lsp] Loaded lsp-wrapper.sh"