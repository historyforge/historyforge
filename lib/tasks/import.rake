# frozen_string_literal: true

# The entire purpose of this is for a developer to bootstrap a database with some census records exported with the
# CSV button on HistoryForge.
namespace :import do
  task census: :environment do
    year = ENV['YEAR']
    raise ArgumentError('You must pass in a YEAR argument') if year.blank?

    csv_file = ENV['FILE']
    raise ArgumentError('You must pass in a valid file path as the FILE argument') unless File.exists?(csv_file)

    require 'csv'

    CSV.foreach(csv_file, headers: true) do |row|
      # puts row.inspect
      record = CensusRecord.for_year(year).find_or_initialize_by(
        city: row['City'],
        ward: row['Ward'],
        enum_dist: row['Enum Dist'],
        page_number: row['Sheet'],
        page_side: row['Side'],
        line_number: row['Line']
      )
      # puts record.inspect
      row.each do |key, value|
        if key == 'Locality'
          record.locality = Locality.find_or_create_by(name: value)
          next
        end

        next if value.nil? || value == ''

        begin
          attribute = DataDictionary.field_from_label(key, year)
        rescue ArgumentError
          next
        end
        next unless attribute && record.has_attribute?(attribute)

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

    record.ensure_building = true
    record.save!
  end
end
