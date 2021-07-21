namespace :db do

  desc "Dumps the database to db/APP_NAME.dump"
  task :dump => :environment do
    cmd = nil
    with_config do |app, host, db, user, password|
      system "PGPASSWORD=#{password} pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end
  end

  desc "Restores the database dump at db/APP_NAME.dump. To use the backup from up to 7 days ago, pass in the days argument like so: rake db:restore days=2"
  task :restore => :environment do
    timestamp = ENV['days'] ? ENV['days'].days.ago : Time.now
    timestamp = timestamp.strftime('%Y-%m-%d')
    cmd = nil
    with_config do |app, host, db, user, password|
      file = File.join Rails.root, 'db', "#{app}-#{timestamp}.dump"
      cmd = "PGPASSWORD=#{password} pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{file}"
    end
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    system cmd
  end

  desc 'Performs a rolling 7 day backup when invoked via cron.'
  task :backup => :dump do
    require 'fileutils'
    basename = File.join(Rails.root, 'db', Rails.application.class.parent_name.underscore)
    timestamp = Time.now.strftime('%Y-%m-%d')
    expired = 7.days.ago.strftime('%y-%m-%d')
    FileUtils.mv "#{basename}.dump", "#{basename}-#{timestamp}.dump"
    FileUtils.rm "#{basename}-#{expired}.dump", force: true
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
        ActiveRecord::Base.connection_config[:host],
        ActiveRecord::Base.connection_config[:database],
        ActiveRecord::Base.connection_config[:username],
        ActiveRecord::Base.connection_config[:password]
  end

end
