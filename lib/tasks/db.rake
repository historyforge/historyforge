# lib/tasks/db.rake
# frozen_string_literal: true

namespace :db do
  desc 'Checks to see if the database exists'
  task exists: :environment do
    exists = ActiveRecord::Base.connection.database_exists?
    puts exists
    exit exists ? 0 : 1
  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad
    puts false
    exit 1
  end

  desc 'checks to see if the schema exists'
  task schema_exists: :environment do
    exists = ActiveRecord::Base.connection.table_exists?('public.action_text_rich_texts')
    puts exists
    exit exists ? 0 : 1
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    puts false
    exit 1
  end

  desc 'Checks to see if the database is empty'
  task is_empty: :environment do
    empty = ActiveRecord::Base.connection.schema_version.nil? ||
            ActiveRecord::Base.connection.schema_version.zero? ||
            ActiveRecord::Base.connection.tables.empty?
    puts empty
    exit empty ? 0 : 1
  end

  desc 'Checks to see if the database has pending migrations'
  task has_pending_migrations: :environment do
    migration_context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
    pending = migration_context.needs_migration?
    puts pending
    exit pending ? 0 : 1
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    puts false
    exit 1
  end
end
