namespace :census do
  task format: :environment do
    [Census1900Record, Census1910Record, Census1920Record, Census1930Record, Census1940Record].each do |klass|
      klass.find_each do |record|
        record.validate
        record.save(validate: false) if record.changed?
      end
    end
  end

  task format_names: :environment do
    [Census1900Record, Census1910Record, Census1920Record, Census1930Record, Census1940Record].each do |klass|
      klass.where("name_suffix IS NOT NULL OR name_prefix IS NOT NULL").each do |record|
        record.validate
        record.save(validate: false) if record.changed?
      end
    end
  end
end
