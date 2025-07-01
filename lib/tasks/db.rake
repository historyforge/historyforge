  # lib/tasks/db.rake
namespace :db do
  desc 'Checks to see if the database exists'
  task exists: :environment do
    ActiveRecord::Base.connection.database_exists?
  end

  desc 'checks to see if the schema exists'
  task schema_exists: :environment do
    ActiveRecord::Base.connection.schema_exists?
    puts 'Schema exists.'
    exit 0 # Success: schema exists
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    puts 'Schema does not exist.'
    exit 1 # Failure: schema does not exist
  end

  desc 'Checks to see if the database is empty'
  task is_empty: :environment do
    if ActiveRecord::Base.connection.schema_version.nil? ||
       ActiveRecord::Base.connection.schema_version.zero? ||
       ActiveRecord::Base.connection.tables.empty?
      puts 'Database is empty.'
      exit 0 # Success: database is empty
    else
      puts 'Database is not empty.'
      exit 1 # Failure: database is not empty
    end
  end
end
