# frozen_string_literal: true

namespace :people do
  task audit_names: :environment do
    Person.preload(:names).find_each do |person|
      primary_name = person.primary_name
      person.names.each do |name|
        next if primary_name.eql?(name)

        # If the first name is a prefix and prefix is null then let's move the first name to the prefix and set the first name to null
        if name.name_prefix.blank? && (name.first_name == 'Mr' || name.first_name == 'Mrs')
          name.update(name_prefix: name.first_name, first_name: nil)
        end

        unless (name.first_name && primary_name.first_name && name.first_name.casecmp(primary_name.first_name).zero?) && (name.last_name && primary_name.last_name && name.last_name.casecmp(primary_name.last_name).zero?)
          next
        end

        primary_name.middle_name ||= name.middle_name
        primary_name.name_prefix ||= name.name_prefix
        primary_name.name_suffix ||= name.name_suffix
        primary_name.save && name.destroy
      rescue StandardError => e
        puts name.inspect
        puts primary_name.inspect
        raise e
      end
    end
  end
  task reindex: :environment do
    CensusYears.each do |year|
      PgSearch::Multisearch.rebuild("Census#{year}Record".constantize)
    end
  end
  task cultivate: :environment do
    ActiveRecord::Base.connection.execute <<~SQL
      DELETE FROM people WHERE id IN(
          SELECT people.id FROM people LEFT OUTER JOIN people_photographs ON people_photographs.person_id=people.id
            LEFT OUTER JOIN census_1880_records ON people.id=census_1880_records.person_id
            LEFT OUTER JOIN census_1900_records ON people.id=census_1900_records.person_id
            LEFT OUTER JOIN census_1910_records ON people.id=census_1910_records.person_id
            LEFT OUTER JOIN census_1920_records ON people.id=census_1920_records.person_id
            LEFT OUTER JOIN census_1930_records ON people.id=census_1930_records.person_id
            LEFT OUTER JOIN census_1940_records ON people.id=census_1940_records.person_id
            LEFT OUTER JOIN census1950_records ON people.id=census1950_records.person_id
            WHERE people_photographs.photograph_id IS NULL AND census_1880_records.id IS NULL AND census_1900_records.id IS NULL
              AND census_1910_records.id IS NULL AND census_1920_records.id IS NULL AND census_1930_records.id IS NULL
              AND census_1940_records.id IS NULL AND census1950_records.id IS NULL
          )
    SQL
  end
  task connect: :environment do
    CensusYears.each do |year|
      CensusRecord.for_year(year).ids.each do |id|
        MatchCensusToPersonRecordJob.new.perform(year, id)
      end
      CensusRecord.for_year(year).find_each &:save
    end
  end
  task age_and_race: :environment do
    Person.find_each &:save
  end
end
