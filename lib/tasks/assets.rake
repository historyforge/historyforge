if ENV['RAILS_ENV'] == 'production' && !ENV['DEPLOYING']
  namespace :assets do
    task precompile: :environment do
      puts "Skipping asset precompile."
    end
  end
end