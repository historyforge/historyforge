# .ruby-lsp.rb
require "rubocop"
puts "[ruby-lsp] Loaded .ruby-lsp.rb"

# Force-load this specific constant to prevent autoload race
RuboCop::Cop::Offense

# Force-load this specific constant to prevent autoload race
RuboCop::Cop::Error