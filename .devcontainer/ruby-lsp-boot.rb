require "rubygems"
require "bundler/setup"
require "rubocop"
require "ruby-lsp"
#!/usr/bin/env ruby
# frozen_string_literal: true

# Optionally output some diagnostics
puts "[ruby-lsp-boot.rb] Booting Ruby LSP..."

# You can require dotenv or do other pre-load logic here if needed

# Forward to Shopify's activation entrypoint
require File.expand_path(
  "~/.vscode-server/extensions/shopify.ruby-lsp-0.9.28/activation.rb"
)

puts "[ruby-lsp] Loaded .ruby-lsp-boot.rb"