web: bundle exec rails server -p 5000 -b 0.0.0.0
worker: bundle exec sidekiq -t 1 -q default -q mailers -q active_storage_analysis -q active_storage_purge
console: bundle exec rails console
