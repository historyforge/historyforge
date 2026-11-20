# frozen_string_literal: true

namespace :people do
  desc 'Preview legacy estimated death years last updated before BEFORE (ISO 8601). Set APPLY=1 to mark them exact.'
  task mark_legacy_death_years_exact: :environment do
    cutoff = Time.iso8601(ENV.fetch('BEFORE'))
    candidates = Person.where(is_death_year_estimated: true, updated_at: ...cutoff).where.not(death_year: nil)

    if ENV['APPLY'] == '1'
      count = candidates.update_all(is_death_year_estimated: false, updated_at: Time.current)
      puts "Marked #{count} death years exact."
    else
      puts "#{candidates.count} death years would be marked exact."
    end
  end

  task reindex: :environment do
    CensusYears.each do |year|
      PgSearch::Multisearch.rebuild("Census#{year}Record".constantize)
    end
  end

  task audit_names: :environment do
    Person.includes(:names).find_each do |person|
      person.names.each(&:save)
      variant_names = person.variant_names
      next if variant_names.blank?

      found_primary_name = false
      variant_names.each do |name|
        if name.first_name == person.first_name && name.last_name == person.last_name
          if found_primary_name
            Flag.create(
              flaggable: person,
              reason: 'incorrect',
              message: "Possible extra name variant: first name \"#{name.first_name}\" and last name \"#{name.last_name}\"."
            )
          else
            found_primary_name = true
          end
        end

        next unless name.name == person.name

        Flag.create(
          flaggable: person,
          reason: 'incorrect',
          message: "Possible extra name variant: first name \"#{name.first_name}\" and last name \"#{name.last_name}\"."
        )
      end
    end
  end
end
