  # lib/tasks/db.rake
namespace :db do
  desc 'Checks to see if the database exists'
  task exists: :environment do
    begin
      ActiveRecord::Base.connection
      puts 'Database exists.'
      exit 0 # Success: database exists
    rescue ActiveRecord::NoDatabaseError
      puts 'Database does not exist.'
      exit 1 # Failure: database does not exist
    end
  end

  desc 'chesks to see if the schema exists'
  task schema_exists: :environment do
    begin
      ActiveRecord::Base.connection.schema_cache
      puts 'Schema exists.'
      exit 0 # Success: schema exists
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      puts 'Schema does not exist.'
      exit 1 # Failure: schema does not exist
    end
  end

  desc 'Checks to see if the database is empty'
  task is_empty: :environment do
    if ActiveRecord::Base.connection.tables.empty?
      puts 'Database is empty.'
      exit 0 # Success: database is empty
    else
      puts 'Database is not empty.'
      exit 1 # Failure: database is not empty
    end
  end
end
