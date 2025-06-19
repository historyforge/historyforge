begin
  require 'rubocop'
  puts '✅ RuboCop loaded'
  puts "RuboCop::Cop is #{RuboCop::Cop}"
rescue => e
  puts '❌ RuboCop NOT loaded'
  puts e.full_message
end

if defined?(RubyLsp)
  begin
    require "rubocop"
    puts "[LSP Patch] RuboCop required manually."
  rescue LoadError => e
    puts "[LSP Patch] Failed to load RuboCop: #{e.message}"
  end
end