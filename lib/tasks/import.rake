# frozen_string_literal: true

# The entire purpose of this is for a developer to bootstrap a database with some census records exported with the
# CSV button on HistoryForge.
namespace :import do
  task census: :environment do
    year = ENV['YEAR']
    raise ArgumentError('You must pass in a YEAR argument') if year.blank?

    csv_file = ENV['FILE']
    raise ArgumentError('You must pass in a valid file path as the FILE argument') unless File.exist?(csv_file)

    rows_count = 0
    saved_count = 0

    Setting.load

    require 'csv'

    CSV.foreach(csv_file, headers: true) do |row|
      record = CensusRecord.for_year(year).find_or_initialize_by(
        city: row['City'],
        ward: row['Ward'],
        enum_dist: row['Enum Dist'],
        page_number: row['Sheet'],
        page_side: row['Side'],
        line_number: row['Line']
      )

      row.each do |key, value|
        if key == 'Locality'
          record.locality = Locality.find_or_create_by(name: value)
        elsif !value.nil? && value != ''
          attribute = DataDictionary.field_from_label(key, year) rescue nil
          if attribute && record.has_attribute?(attribute) && attribute != 'person_id'
            if value == 'Yes'
              record[attribute] = true
            elsif DataDictionary.coded_attribute?(attribute)
              code = DataDictionary.code_from_label(key, value)
              record[attribute] = code
            else
              record[attribute] = value
            end
          end
        end
      end

      record.created_by = User.first

      address = Address.find_or_initialize_by house_number: record.street_house_number,
                                              prefix: record.street_prefix,
                                              name: record.street_name,
                                              suffix: record.street_suffix,
                                              city: record.city,
                                              is_primary: true

      record.building = address.building || Building.create(
        name: address,
        locality: record.locality,
        building_type_ids: [1],
        lat: row['Latitude'],
        lon: row['Longitude'],
        addresses: [address]
      )

      # Not going to sweat if the record doesn't save because this is just for developers to load some census records
      rows_count += 1
      record.save && saved_count += 1
    end

    puts "Managed to load #{saved_count} of #{rows_count} records.\n"
  end

end
