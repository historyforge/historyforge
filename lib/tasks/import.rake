# frozen_string_literal: true
require 'benchmark'
require 'csv'

namespace :import do

  desc 'Import parcel file into HistoryForge, updating if it exists'
  task parcel: :environment do
    year = ENV.fetch('YEAR', nil)
    raise ArgumentError('You must pass in a YEAR argument') if year.blank?

    csv_file = ENV.fetch('FILE', nil)
    raise ArgumentError('You must pass in a valid file path as the FILE argument') unless File.exist?(csv_file)

    Setting.load

    rows = CSV.read(csv_file, headers: true)
    # Fail early if 'id' column is present
    raise ArgumentError, "CSV file must not contain an 'id' column." if rows.headers.map(&:downcase).include?('id')

    rows_count = rows.size
    saved_count = 0

    rows.each_with_index do |row, _index|
      record = build_census_record(row, year)
      assign_census_attributes(record, row, year)
      record.created_by = User.first
      assign_census_building(record, row)
      saved_count += 1 if record.save
    end

    CSV.foreach(csv_file, headers: true) do |row|
      record =Parcel.find_or_initialize_by(
        parcelid: row['ParcelID'],
        sheet: row['Sheet'],
        row: row['Row'],
        grantor: row['Grantor'],
        grantee: row['Grantee'],
        instrument: row['Instrument'],
        lots: [row['Lot(s)']],
        block: row['Block'],
        subdivision: row['Subdivision'],
        book: row['Book'],
        page: row['Page'],
        date: row['Date'],
        dl: row['DL'],
        document_link: row['Document Link'],
        contact_link: row['Concat Link']
      )
      rows_count += 1
      record.save && saved_count += 1
      puts "Managed to load #{saved_count} of #{rows_count} records.\n"
    end
  end

  desc 'Import census file into HistoryForge, updating if it exists'
  task census: :environment do
    year = ENV.fetch('YEAR', nil)
    raise ArgumentError, 'You must pass in a YEAR argument' if year.blank?

    csv_file = ENV.fetch('FILE', nil)
    raise ArgumentError, 'You must pass in a valid file path as the FILE argument' unless File.exist?(csv_file)

    Setting.load

    rows = CSV.read(csv_file, headers: true)
    # Fail early if 'id' column is present
    raise ArgumentError, "CSV file must not contain an 'id' column." if rows.headers.map(&:downcase).include?('id')

    rows_count = rows.size
    saved_count = 0

    rows.each_with_index do |row, _index|
      record = build_census_record(row, year)
      assign_census_attributes(record, row, year)
      record.created_by = User.first
      assign_census_building(record, row)
      saved_count += 1 if record.save
    end

    puts "Managed to load #{saved_count} of #{rows_count} records.\n"
  end

  desc 'Import parcel records in parallel from a CSV file'
  # rake import:parcel_parallel[1930,path/to/file.csv,true,true]
  task :parcel_parallel, [:year, :file, :dry_run, :json] => :environment do |_, args|
    require 'parallel'
    require 'ruby-progressbar'
    PaperTrail.request(enabled: false) do
      raise ArgumentError, 'You must provide a YEAR' if args[:year].blank?
      raise ArgumentError, 'You must provide a valid FILE path' unless File.exist?(args[:file])

      dry_run = parse_bool_arg(args[:dry_run])
      json_output = parse_bool_arg(args[:json])

      Setting.load
      rows = CSV.read(args[:file], headers: true)
      rows_count = rows.size
      puts "Starting #{dry_run ? 'dry run of' : 'import of'} #{rows_count} parcel records..."

      progress = ProgressBar.create(
        title: 'Parcels',
        total: rows_count,
        format: '%t [%B] %c/%C',
        output: json_output ? File.open(File::NULL, 'w') : $stdout
      )

      results = Parallel.map(rows.each_with_index, in_threads: Etc.nprocessors) do |row, index|
        begin
          record = Parcel.find_or_initialize_by(
            parcelid: row['ParcelID'],
            sheet: row['Sheet'],
            row: row['Row'],
            grantor: row['Grantor'],
            grantee: row['Grantee'],
            instrument: row['Instrument'],
            lots: [row['Lot(s)']],
            block: row['Block'],
            subdivision: row['Subdivision'],
            book: row['Book'],
            page: row['Page'],
            date: row['Date'],
            dl: row['DL'],
            document_link: row['Document Link'],
            contact_link: row['Concat Link']
          )

          if dry_run || record.save
            { index:, status: :ok }
          else
            { index:, status: :error, errors: record.errors.full_messages, data: row.to_h }
          end
        rescue StandardError => e
          { index:, status: :error, errors: [e.message], data: row.to_h }
        ensure
          progress.increment
        end
      end

      summarize_results(results:, type: 'parcel', dry_run:, json_output:)
    end
  end

  desc 'Import census records in parallel from a CSV file'
  # rake import:census_parallel[1930,path/to/file.csv,true,true]
  task :census_parallel, %i[year file dry_run json] => :environment do |_, args|
    require 'parallel'
    require 'ruby-progressbar'
    PaperTrail.request(enabled: false) do
      validate_census_args!(args)
      year = args[:year]
      dry_run = parse_bool_arg(args[:dry_run])
      json_output = parse_bool_arg(args[:json])

      null_logger = Logger.new(IO::NULL)
      original_logger = ActiveRecord::Base.logger

      ActiveRecord::Base.logger = null_logger

      Setting.load
      rows = CSV.read(args[:file], headers: true)
      # Fail early if 'id' column is present
      raise ArgumentError, "CSV file must not contain an 'id' column." if rows.headers.map(&:downcase).include?('id')

      rows_count = rows.size
      puts "Starting #{dry_run ? 'dry run of' : 'import of'} #{rows_count} census records for year #{year}..."

      progress = ProgressBar.create(
        title: 'Census',
        total: rows_count,
        format: '%t [%B] %c/%C',
        output: json_output ? File.open(File::NULL, 'w') : $stdout
      )

      results = Parallel.map(rows.each_with_index, in_threads: Etc.nprocessors) do |row, index|
        process_census_row(row:, index:, year:, dry_run:, progress:)
      end

      ActiveRecord::Base.logger = original_logger

      nil_indices = results.each_index.select { |i| results[i].nil? }
      puts "Nil at indices: #{nil_indices.inspect}" unless nil_indices.empty?

      summarize_results(results:, type: 'census', dry_run:, json_output:)
    end
  end

  def validate_census_args!(args)
    raise ArgumentError, 'You must provide a YEAR' if args[:year].blank?
    raise ArgumentError, 'You must provide a valid FILE path' unless File.exist?(args[:file])
  end

  def process_census_row(row:, index:, year:, dry_run:, progress:)
    result = nil
    begin
      ActiveRecord::Base.transaction do
        record = build_and_assign_census_record(row:, year:)
        result = census_row_result(record:, row:, index:, dry_run:)
      end
      return result
    rescue ActiveRecord::ActiveRecordError => e
      result ||= { index:, status: :error, errors: [e.message], data: row.to_h }
      return result
    rescue StandardError => e
      result = { index:, status: :error, errors: [e.message], data: row.to_h }
      return result
    ensure
      progress.increment
    end
    result
  end

  def build_and_assign_census_record(row:, year:)
    record = build_census_record(row:, year:)
    assign_census_attributes(record:, row:, year:)
    record.created_by = User.first
    assign_census_building(record:, row:)
    record
  end

  def census_row_result(record:, row:, index:, dry_run:)
    Thread.current[:skip_vocabulary_validation] = true
    current_user = User.first || nil
    if dry_run
      result = []
      ActiveRecord::Base.transaction(requires_new: true) do
        saved = record.save
        errors = record.errors.full_messages
        result << {
          index:,
          status: saved ? :ok : :error,
          errors: saved ? [] : errors,
          data: saved ? nil : row.to_h
        }
        raise ActiveRecord::Rollback # Always rollback
      rescue StandardError => e
        result << {
          index:,
          status: :error,
          errors: [e.message],
          data: row.to_h
        }
      end
      result.first
    elsif record.save
      record.review!(current_user)
      record.auto_generate_person_record
      { index:, status: :ok }
    else
      raise ActiveRecord::ActiveRecordError, "Census record invalid: #{record.errors.full_messages.join(', ')}"
    end
  end

  def build_census_record(row:, year:)
    CensusRecord.for_year(year).find_or_initialize_by(
      city: row['City'],
      ward: row['Ward'],
      enum_dist: row['Enum Dist'],
      page_number: row['Sheet'],
      page_side: row['Side'],
      line_number: row['Line']
    )
  end

  def assign_census_attributes(record:, row:, year:)
    row.each do |key, value|
      next if value.blank?

      if key == 'Locality'
        record.locality = Locality.find_or_create_by(name: value, short_name: value)
        next
      end
      attribute = begin
        DataDictionary.field_from_label(key, year)
      rescue StandardError
        nil
      end
      dc_attribute = attribute&.downcase&.strip
      next unless dc_attribute && record.has_attribute?(dc_attribute) && dc_attribute != 'person_id'

      record[dc_attribute] =
        if value == 'Yes'
          true
        elsif dc_attribute == 'language'
          DataDictionary.code_from_label(value, dc_attribute)
        else
          value
        end
    end
    record.county ||= row['County']
    record.state  ||= row['State']
  end

  def assign_census_building(record:, row:)
    address = Address.find_or_initialize_by(
      house_number: record.street_house_number,
      prefix: record.street_prefix,
      name: record.street_name,
      suffix: record.street_suffix,
      city: record.city,
      is_primary: true
    )
    record.building = address.building || Building.create(
      name: address.address.split(address.city.to_s).first.strip,
      locality: record.locality,
      building_type_ids: [1],
      lat: row['Latitude'],
      lon: row['Longitude'],
      addresses: [address]
    )
  end

  require 'json'

  def summarize_results(results:, type:, dry_run:, json_output: false)
    successes = results.count { |r| r[:status] == :ok }
    failures = results.select { |r| r[:status] == :error }

    if json_output
      print_json_summary(type:, dry_run:, results:, successes:, failures:)
    else
      print_text_summary(type:, dry_run:, results:, successes:, failures:)
    end
  end

  def print_json_summary(type:, dry_run:, results:, successes:, failures:)
    puts({
      type:,
      mode: dry_run ? 'dry_run' : 'import',
      total: results.size,
      successful: successes,
      failed: failures.size,
      errors: failures.map { |f| format_failure_json(f) }
    }.to_json)
  end

  def format_failure_json(failure:)
    {
      index: failure[:index] + 1,
      errors: failure[:errors],
      data: failure[:data]
    }
  end

  def print_text_summary(type:, dry_run:, results:, successes:, failures:)
    failures.any? && print_failures(failures:, dry_run:)
    puts "\n✅ #{dry_run ? 'Would import' : 'Successfully imported'} #{successes} of #{results.size} #{type} records."
  end

  def print_failures(failures:, dry_run:)
    grouped = failures.group_by { |f| f[:errors].join('; ') }

    puts "\n⚠️ Failed to #{dry_run ? 'simulate' : 'import'} #{failures.size} records in #{grouped.keys.size} error group(s):"

    grouped.each do |error_message, group|
      row_indices = group.map { |f| f[:index] + 1 }
      ids = group.filter_map { |f| f[:data]['id'] }.uniq
      puts "\n--- #{group.size} record(s) failed with error: #{error_message} ---"
      puts "Rows: #{row_indices.inspect}"
      puts "IDs: #{ids.inspect}" unless ids.empty?
    end
  end

  def parse_bool_arg(value) # rubocop:disable Naming/PredicateMethod
    return false if value.nil?

    value = value.to_s.strip
    value = value.split('=').last if value.include?('=')
    value.downcase == 'true'
  end
end
