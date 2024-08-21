# frozen_string_literal: true

namespace :people do
  task reindex: :environment do
    CensusYears.each do |year|
      PgSearch::Multisearch.rebuild("Census#{year}Record".constantize)
    end
  end

  task audit_names: :environment do
    PersonName.update_all(name_prefix: nil, name_suffix: nil, middle_name: nil)
    Person.includes(:names).find_each do |person|
      variant_names = person.variant_names
      next if variant_names.blank?

      found_primary_name = false
      variant_names.each do |name|
        if name.first_name == person.first_name && name.last_name == person.last_name
          if found_primary_name
            name.destroy
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

      person.add_name_from!(person) unless found_primary_name
    end
  end
end
